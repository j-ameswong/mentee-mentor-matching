get "/accounts" do
  redirect "/login" unless session[:logged_in]

  @limit = User.count
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  $offset = 0
  @users = User.limit(@limit).offset($offset * @limit).all

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
      user.delete_from_all
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
  $num_pages = 1

  if @limit > 10
    $num_pages = (@limit / 10).to_i
    @limit = 10
  end

  $offset = 0
  @users = User.limit(@limit).offset($offset).where(@cond)

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