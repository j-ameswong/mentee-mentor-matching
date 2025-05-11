get "/accounts" do
  redirect "/login" unless session[:logged_in]

  @limit = User.count
  @num_pages = 1

  if @limit > 10
    @num_pages = (@limit / 10).to_i
    @limit = 10
  end

  @offset = 0
  @users = User.limit(@limit).offset(@offset).all

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
  @num_pages = 1

  if @limit > 10
    @num_pages = (@limit / 10).to_i
    @limit = 10
  end

  @offset = 0
  @users = User.limit(@limit).offset(@offset).where(@cond)
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

post "/accounts/action" do
  redirect "/login" unless session[:logged_in]

  if params[:action] == "delete"
    @users = User.where(id: params[:user_id])
    @users.each do |user|
      # TODO: delete user
      # unless user[:role] == "admin"
      #   if user[:role] == "mentor"
      #     MentorProfile.where(user_id: user[:id]).delete
      #     Match.where(mentor_id: user[:id]).delete
      #   else
      #     MenteeProfile.where(user_id: user[:id]).delete
      #     Match.where(mentee_id: user[:id]).delete
      #   end
      #   Profile.where(user_id: user[:id]).delete
      #   end
      # Authentication.where(user_id: user[:id]).delete
      # UserExpertise.where(user_id: user[:id]).delete
      # User.where(id: user[:id]).delete
    end
  end

  if params[:action] == "reassign"
    @users = User.where(id: params[:user_id])
    @users.each do |user|
      # TODO: reassign user
    end
  end

  if params[:action] == "badges"
    @mentors = MentorProfile.where(id: params[:user_id])
    @mentors.each do |mentor|
      mentor[:badges] = "Experienced Mentor"
      # puts mentor.inspect
      # puts mentor[:badges].inspect
    end
  end

  @cond = {}
  unless params[:username].empty?
    @cond[:username] = params[:username]
  end
  unless params[:role].empty?
    @cond[:role] = params[:role]
  end

  @limit = User.count
  @num_pages = 1

  if @limit > 10
    @num_pages = (@limit / 10).to_i
    @limit = 10
  end

  @offset = 0
  @users = User.limit(@limit).offset(@offset).where(@cond)

  @actions = Array.new(@limit) { ["delete", "reassign"] }

  i = 0
  @users.each { |user|
    if user[:role] == "mentor"
      if MentorProfile.where(user_id: user[:id]).limit(1).pluck(:year_of_study).first >= 4
        @actions[i] = ["delete", "reassign", "badges"]
      end
    end
    i += 1
  }

  erb :manageAccounts
end

post "/accounts/next" do
  @offset = @offset + 1;
end

post "/accounts/prev" do
  @offset = @offset - 1;
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