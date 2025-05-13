before do
  @flash = session.delete(:flash) || {}
end

get "/accounts" do
  redirect "/login" unless session[:logged_in]

  @flash = { error: "This is a test flash message" }

  if params[:flag_status]
    session[:account_filters] ||= {}
    session[:account_filters][:flag_status] = params[:flag_status]
  end

  @limit = User.count
  @num_pages = 1

  if @limit > 10
    @num_pages = (@limit / 10).to_i
    @limit = 10
  end

  @offset = 0
  
  @cond = {}
  if session[:account_filters]
    unless session[:account_filters][:username].to_s.empty?
      @cond[:username] = Sequel.like(:username, "%#{session[:account_filters][:username]}%")
    end
    unless session[:account_filters][:role].to_s.empty?
      @cond[:role] = session[:account_filters][:role]
    end
    unless session[:account_filters][:email].to_s.empty?
      @cond[:email] = Sequel.like(:email, "%#{session[:account_filters][:email]}%")
    end
  end
  
  @users = User.limit(@limit).offset(@offset).where(@cond).all
  
  if session[:account_filters] && !session[:account_filters][:flag_status].to_s.empty?
    flag_status = session[:account_filters][:flag_status] == "1"
    @users = @users.select { |user| user.flagged? == flag_status }
  end

  @actions = []
  @users.each do |user|
    actions = ["delete", "reassign"]
    
    if user[:role] == "mentor" && 
       !MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first.nil? &&
       MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first >= 4
      actions << "badges"
    end
    
    @actions << actions
  end

  erb :manageAccounts
end

post "/accounts" do
  redirect "/login" unless session[:logged_in]

  session[:account_filters] = {
    username: params[:username],
    email: params[:email],
    role: params[:role],
    flag_status: params[:flag_status]
  }

  redirect "/accounts"
end

post "/accounts/action" do
  redirect "/login" unless session[:logged_in]

  user = User.first(id: params[:user_id].to_i)
  
  case params[:action]

  when "delete"
    user.delete_from_all if user

  when "reassign"
    # TODO: Implement reassign functionality

  when "badges"
    mentor_profile = MentorProfile.first(user_id: user.id)
    if mentor_profile
      mentor_profile.update(badges: "Experienced Mentor")
      mentor_profile.save
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
        else
          session[:flash] = { error: "A mentor must have at least one completed match to gain a badge." }
        end
      else
        session[:flash] = { error: "Mentor must be a fourth year student to gain a badge." }
        puts "FLASH SET: #{session[:flash].inspect}" 
      end
    end

  when "flag"

  when "unflag"
    user.unflag if user
  end

  redirect "/accounts"
end

post "/accounts/next" do
  @offset = session[:offset] || 0
  session[:offset] = @offset + 10
  redirect "/accounts"
end

post "/accounts/prev" do
  @offset = session[:offset] || 0
  session[:offset] = [@offset - 10, 0].max
  redirect "/accounts"
end

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

post "/flag" do
  redirect "/login" unless session[:logged_in]
  
  user_id = params[:user_id].to_i
  reasoning = params[:flag_reasoning].strip
  
  user = User.first(id: user_id)
  if user && !reasoning.empty?
    user.flag(reasoning)
  end
  
  redirect "/accounts"
end

post "/unflag/:id" do
  redirect "/login" unless session[:logged_in]
  
  user = User.first(id: params[:id].to_i)
  if user
    user.unflag
  end
  
  redirect "/accounts"
end

post "/delete/:id" do
  redirect "/login" unless session[:logged_in]
  
  user = User.first(id: params[:id].to_i)
  if user
    user.delete_from_all
  end
  
  redirect "/accounts"
end