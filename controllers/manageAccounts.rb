before do
  @flash = session.delete(:flash) || {}
end

# TODO ON LOAD PAGE INIT (not a todo just so comment stands out)
get "/accounts" do
  redirect "/login" unless session[:logged_in]

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
  if $offset.nil?
    $offset = 0
  end

  @users = User.limit(@limit).offset($offset * @limit).all

  @actions = Array.new(@limit) { ["delete", "reassign"] }

  i = 0
  @users.each do |user|
    if user[:role] == "mentor" && !MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first.nil? &&
       MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first >= 4
      @actions[i] = ["delete", "reassign", "badges"]
    end
  end

  if $cond.nil?
    @users = User.limit(@limit).offset($offset * @limit).all
  else
    @users = User.limit(@limit).offset($offset).where($cond).all
  end

  if !session[:account_filters].nil? && !session[:account_filters][:flag_status].to_s.empty?
    flag_status = session[:account_filters][:flag_status] == "1"
    @users = @users.select { |user| user.flagged? == flag_status }
  end

  @actions = []
  @users.each do |user|
    actions = ["reassign"]

    if user[:role] == "mentor" &&
       !MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first.nil? &&
       MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first >= 4
      actions << "badges"
    end

    @actions << actions
  end

  puts @users.size
  erb :manageAccounts
end

# TODO ON FILTERS UPDATE (not a todo just so comment stands out)
post "/accounts" do
  redirect "/login" unless session[:logged_in]

  session[:account_filters] = {
    username: params[:username],
    email: params[:email],
    role: params[:role],
    flag_status: params[:flag_status]
  }
  $cond = {}
  unless params[:username].empty?
    $cond[:username] = params[:username]
  end
  unless params[:role].empty?
    $cond[:role] = params[:role]
  end
  unless params[:email].empty?
    $cond[:email] = params[:email]
  end

  puts $cond

  @limit = User.count
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  $offset = 0
  if $cond
    @users = User.limit(@limit).offset($offset * @limit).where($cond)
  else
    @users = User.limit(@limit).offset($offset * @limit)
  end
  # puts @users.inspect

  @actions = Array.new(@limit) { ["delete", "reassign"] }

  i = 0
  @users.each { |user|
    if user[:role] == "mentor" && !MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first.nil? &&
       MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first >= 4
      @actions[i] = ["delete", "reassign", "badges"]
    end
    i += 1
  }

  erb :manageAccounts
end

# TODO WHEN ACTION SELECTED IN TABLE (not a todo just so comment stands out)
post "/accounts/action" do
  redirect "/login" unless session[:logged_in]

  user = User.first(id: params[:user_id].to_i)

  case params[:action]

  when "reassign"
    # TODO: Implement reassign functionality

  when "badges"
    mentor_profile = MentorProfile.first(user_id: user.id)
    if mentor_profile
      mentor_profile.update(badges: "Experienced Mentor")
      mentor_profile.save
    end
    if params[:action] == "delete"
      @users = User.where(id: params[:user_id])
      @users.each do |user|
        user.delete_from_all
      end
    end

  when "apply_badge"
    if user && user.role == "mentor"
      mentor_profile = MentorProfile.first(user_id: user.id)

      if mentor_profile && mentor_profile.year_of_study >= 4
        matches = Match.where(mentor_id: user.id).all
        eligible_match_exists = matches.any? do |match|
          match.status == "completed"
        end

        if eligible_match_exists
          mentor_profile.update(badges: "Experienced Mentor")
          session[:flash] = { success: "Badge applied successfully." }
          puts "FLASH SET: #{session[:flash].inspect}"
        else
          session[:flash] = { error: "A mentor must have at least one completed match to gain a badge." }
          puts "FLASH SET: #{session[:flash].inspect}"
        end
      else
        session[:flash] = { error: "Mentor must be a fourth year student to gain a badge." }
        puts "FLASH SET: #{session[:flash].inspect}"
        $cond = {}
        unless params[:username].empty?
          $cond[:username] = params[:username]
        end
        unless params[:role].empty?
          $cond[:role] = params[:role]
        end
      end
    end
  else
    # type code here
  end

  @limit = User.count
  $num_pages = 1
  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  $offset = 0
  @users = User.limit(@limit).offset($offset).where($cond)

  @actions = Array.new(@limit) { ["delete", "reassign"] }
  i = 0
  @users.each { |user|
    if user[:role] == "mentor"
      if MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first >= 4
        @actions[i] = ["delete", "reassign", "badges"]
      end
    end
  }
  redirect "/accounts"
end

# TODO WHEN NEXT PAGE BUTTON CLICKED ON TABLE (not a todo just so comment stands out)
post "/accounts/next" do
  if $offset < $num_pages
    $offset += 1
  end
  redirect "/accounts"
end

# TODO WHEN PREV PAGE CLICKED ON TABLE (not a todo just so comment stands out)
post "/accounts/prev" do
  if $offset > 0
    $offset -= 1
  end
  redirect "/accounts"
end

# TODO WHEN NUMBER OF MATCHES UPDATED (not a todo just so comment stands out)
post "/no-of-matches" do
  redirect "/login" unless session[:logged_in]

  if params[:max_matches]
    max_matches = params[:max_matches].to_i
    mentors = User.where(role: "mentor").all

    mentors.each do |user|
      mentor_profile = MentorProfile.first(user_id: user.id)
      if mentor_profile
        mentor_profile.update(max_matches: max_matches)
        mentor_profile.save
      end
    end
  end

  redirect "/accounts"
end