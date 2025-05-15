# Helper method for safe message sending
def send_admin_notification(sent_by, received_by, message_type)
  begin
    UserMessage.send_message(
      sent_by: sent_by,
      received_by: received_by,
      message_type: message_type
    )
  rescue => e
    puts "Error sending admin notification (#{message_type}): #{e.message}"
  end
end

get "/accounts" do
  redirect "/login" unless session[:logged_in]

  currentEndDate  = GlobalVariable.first(name: "SEMESTER_END_DATE").value
  @endDate = Time.at(currentEndDate).to_date
  puts @endDate

  if params[:flag_status]
    session[:account_filters] ||= {}
    session[:account_filters][:flag_status] = params[:flag_status]
  end

  @limit = User.count
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  $offset = 0
  @users = User.limit(@limit).offset($offset * @limit).all

  # TP
  @actions ||= {}
  @users.each do |user|
    @actions[user.id.to_s] = []
    @actions[user.id.to_s] << "delete"
    if user.mentor? && user.mentor_profile && user.mentor_profile.year_of_study >= 4 && Match.first(mentor_id: user.id, status: "completed")
      @actions[user.id.to_s] << "badge"
    elsif user.mentee? && Match.first(mentee_id: user.id, status: "active")
      @actions[user.id.to_s] << "reassign"
    end
  end

  if params[:show_reassign_modal] && session[:reassign_data]
    mentee_id = session[:reassign_data][:mentee_id]
    current_match = Match.where(mentee_id: mentee_id, status: "active").first
  if $cond.nil?
    @users = User.limit(@limit).offset($offset * @limit).all
  else
    @users = User.limit(@limit).offset($offset).where($cond).all
  end

    if current_match
      @available_mentors = User.where(role: "mentor")
      .join(:mentor_profiles, user_id: :id)
      .select_all(:users)
      .select_append(Sequel[:mentor_profiles][:max_matches])
      .where(Sequel.lit("mentor_profiles.availability = true"))
      .exclude(Sequel[:users][:id] => current_match.mentor_id)
      .all

      @mentor_matches = {}

      @available_mentors.each do |mentor|
        @mentor_matches[mentor[:id]] = Match.where(mentor_id: mentor[:id], status: "active").count  
      end
    end
  end

  erb :manageAccounts
end

post "/accounts" do
  redirect "/login" unless session[:logged_in]

  @cond = {}
  unless params[:username].empty?
    @cond[:username] = params[:username]
  end
  unless params[:role].empty?
    @cond[:role] = params[:role]
  end
  unless params[:email].empty?
    @cond[:email] = params[:email]
  end

  @limit = User.count
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  $offset = 0
  if @cond
    @users = User.limit(@limit).offset($offset * @limit).where(@cond)
  else
    @users = User.limit(@limit).offset($offset * @limit)
  end
  # puts @users.inspect

  @actions ||= {}
  @users.each do |user|
    @actions[user.id.to_s] = []
    @actions[user.id.to_s] << "delete"
    if user.mentor? && user.mentor_profile && user.mentor_profile.year_of_study >= 4 && Match.first(mentor_id: user.id, status: "completed")
      @actions[user.id.to_s.to_s] << "badge"
    elsif user.mentee? && Match.first(mentee_id: user.id, status: "active")
      @actions[user.id.to_s.to_s] << "reassign"
    end
  end

  erb :manageAccounts
end

post "/accounts/action" do
  redirect "/login" unless session[:logged_in]
  #DEBUG
  puts "Action: #{params[:action]}, User ID: #{params[:user_id]}"
  
  if params[:action] == "delete"
    @users = User.where(id: params[:user_id])
    @users.each do |user|
      send_admin_notification(
        session[:user].username || "Admin",
        user.id,
        'account_deleted'
      )
      user.delete_from_all
    end
  end

  if params[:action] == "reassign"
    #DEBUG
    puts "Entering reassign action"
    session[:reassign_user_id] = params[:user_id]
    user = User.where(id: params[:user_id]).first
    #DEBUG
    puts "User: #{user.inspect}"

    if user && user.role == "mentee"
      #DEBUG
      puts "User is a mentee"
      current_match = Match.where(mentee_id: user.id, status: "active").first
      #DEBUG
      puts "Current match: #{current_match.inspect}"
      if current_match
        #DEBUG
        puts "Current match found"
        current_mentor = User.where(id: current_match.mentor_id).first
        #DEBUG
        puts "Current mentor: #{current_mentor.inspect}"
        @available_mentors = User.where(role: "mentor")
        .join(:mentor_profiles, user_id: :id)
        .where(Sequel.lit("mentor_profiles.availability = true"))
        .exclude(Sequel[:users][:id] => current_match.mentor_id)
        .all
        #DEBUG
        puts "Available mentors: #{@available_mentors.inspect}"
        session[:reassign_data] = {
          mentee_id: user[:id],
          mentee_username: user[:username],
          current_mentor_id: current_mentor[:id],
          current_mentor_username: current_mentor[:username],
        }
        puts "Session reassign data: #{session[:reassign_data].inspect}"
        puts "Redirecting to show modal"
        redirect "/accounts?show_reassign_modal=true"
        return
      else
        puts "No active match found for user #{user[:username]}"
        redirect "/accounts"
      end
    else
      error_message = user ? "User #{user[:username]} is not a mentee." : "User does not exist."
      puts error_message
      redirect "/accounts"
    end
  end

  if params[:action] == "badges"
    @mentors = MentorProfile.where(user_id: params[:user_id])
    @mentors.each do |mentor|
      mentor[:badges] = "Experienced Mentor"
      mentor.save  
    UserMessage.send_message(
      sent_by: "Badge System",
      received_by: mentor.user_id,
      message_type: 'badge_applied'
    )
      # puts mentor.inspect
      # puts mentor[:badges].inspect
    end
  end

  @cond = {}
  unless params[:username].nil? || params[:username].empty?
    @cond[:username] = params[:username]
  end
  unless params[:role].nil? ||params[:role].empty?
    @cond[:role] = params[:role]
  end

  @limit = User.count
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  $offset = 0
  @users = User.limit(@limit).offset($offset).where(@cond)
  # TP

  @actions ||= {}
  @users.each do |user|
    @actions[user.id.to_s] = []
    @actions[user.id.to_s] << "delete"
    if user.mentor? && user.mentor_profile && user.mentor_profile.year_of_study >= 4 && Match.first(mentor_id: user.id, status: "completed")
      @actions[user.id.to_s] << "badge"
    elsif user.mentee? && Match.first(mentee_id: user.id, status: "active")
      @actions[user.id.to_s] << "reassign"
    end
  end

  erb :manageAccounts
end

post "/accounts/next" do
  redirect "/login" unless session[:logged_in]

  if $num_pages > 1 && $offset < $num_pages - 1
    redirect "/login" unless session[:logged_in]

    if $offset.nil?
      $offset = 0
    else
      $offset = $offset + 1;
    end

    puts "offset: #{$offset}"
  end

  @limit = User.count
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  if @cond
    @users = User.limit(@limit).offset($offset * @limit).where(@cond)
  else
    @users = User.limit(@limit).offset($offset * @limit)
  end

  @actions ||= {}
  @users.each do |user|
    @actions[user.id.to_s] = []
    @actions[user.id.to_s] << "delete"
    if user.mentor? && user.mentor_profile && user.mentor_profile.year_of_study >= 4 && Match.first(mentor_id: user.id, status: "completed")
      @actions[user.id.to_s] << "badge"
    elsif user.mentee? && Match.first(mentee_id: user.id, status: "active")
      @actions[user.id.to_s] << "reassign"
    end
  end

  erb :manageAccounts
end

post "/accounts/prev" do
  redirect "/login" unless session[:logged_in]
  if $offset > 0
    if $offset.nil?
      $offset = 0
    else
      $offset = $offset - 1;
    end

    puts "offset: #{$offset}"

  end

  @limit = User.count
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  if @cond
    @users = User.limit(@limit).offset($offset * @limit).where(@cond)
  else
    @users = User.limit(@limit).offset($offset * @limit)
  end

  @actions ||= {}
  @users.each do |user|
    @actions[user.id.to_s] = []
    @actions[user.id.to_s] << "delete"
    if user.mentor? && user.mentor_profile && user.mentor_profile.year_of_study >= 4 && Match.first(mentor_id: user.id, status: "completed")
      @actions[user.id.to_s] << "badge"
    elsif user.mentee? && Match.first(mentee_id: user.id, status: "active")
      @actions[user.id.to_s] << "reassign"
    end
  end

  erb :manageAccounts
end

post "/no-of-matches" do
  redirect "/login" unless session[:logged_in]

  if params[:max_matches]
    @users = User.where(role: "mentor").all
    @users.each do |user|
      user[:num_matches] = params[:max_matches]
    end
  end

  redirect "/accounts"
end

<<<<<<< HEAD
post "/reassign-mentee" do
  redirect "/login" unless session[:logged_in]

  mentee_id = params[:mentee_id]
  new_mentor_id = params[:new_mentor_id]
  #DEBUG
  puts "Starting to reasssign mentee #{mentee_id} to mentor #{new_mentor_id}"
  current_match = Match.where(mentee_id: mentee_id, status: "active").first

  if current_match
    old_mentor_id = current_match.mentor_id
    #DEBUG
    puts "The current match for the mentee is #{old_mentor_id}"


    current_match.cancel
    #DEBUG
    puts "Cancelled the current match for mentee #{mentee_id} with mentor #{old_mentor_id}"

    begin 
      puts "Attempting to create a new match"
      new_match = Match.generate!({
        mentor_id: new_mentor_id,
        mentee_id: mentee_id,
        message: "Reassigned from #{current_match.mentor_id} to #{new_mentor_id} by admin"
      })
      #DEBUG
      puts "New match created: #{new_match.inspect}"

      new_match.activate
      #DEBUG
      puts "New match activated for mentee #{mentee_id} with mentor #{new_mentor_id}"

      begin
        # Notify both mentee about reassignment
        UserMessage.send_message(
          sent_by: "System",
          received_by: mentee_id,
          message_type: 'match_reassigned'
        )
        
        # Inform the old mentor about reassignment
        UserMessage.send_message(
          sent_by: "System",
          received_by: old_mentor_id,
          message_type: 'match_reassigned'
        )

         # Notify mentee about new match
        UserMessage.send_message(
          sent_by: "System",
          received_by: mentee_id,
          message_type: 'match_success'
        )
        
        # Notify new mentor about new match
        UserMessage.send_message(
          sent_by: "System",
          received_by: new_mentor_id,
          message_type: 'match_success'
        )
        
        puts "Sent notifications about match reassignment and success"
      rescue => e
        puts "Error sending notifications: #{e.message}"
      end

      mentee = User.where(id: mentee_id).first
      if mentee && mentee.mentee_profile
        mentee.mentee_profile.update(availability: false)
        mentee.mentee_profile.save
        #DEBUG
        puts "Updated mentee profile availability to false"
      end

      new_mentor = User.where(id: new_mentor_id).first
      if new_mentor && new_mentor.mentor_profile
        match_count = Match.where(mentor_id: new_mentor_id, status: "active").count
        new_mentor.mentor_profile.update(num_matches: match_count)
        new_mentor.mentor_profile.save
        #DEBUG
        puts "Updated new mentors match count to #{match_count}"
      end
    end
  else
    #DEBUG
    puts "Reassignment failed: No active match found for mentee #{mentee_id}"
  end

  session[:reassign_user_id] = nil
  session[:reassign_data] = nil

  redirect "/accounts"
end
      
=======
post "/sem-end-date" do
  redirect "/login" unless session[:logged_in]

  if params[:sem_end]
    sem_end = params[:sem_end]
    GlobalVariable.set_semester_end_date(sem_end)
  end

  redirect "/accounts"
end
>>>>>>> frontend
