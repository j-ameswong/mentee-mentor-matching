get "/accounts" do
  redirect "/login" unless session[:logged_in]

  @limit = User.count

  if @limit > 10
    @limit = 10
  end

  @offset = 0
  @users = User.limit(@limit).offset(@offset).all

  erb :manageAccounts
end

post "/accounts" do
  redirect "/login" unless session[:logged_in]

  cond = {}
  unless params[:username].empty?
    cond[:username] = params[:username]
  end
  unless params[:role].empty?
    cond[:role] = params[:role]
  end

  @users = User.limit(@limit).offset(@offset).where(cond)

  erb :manageAccounts
end

post "/accounts/delete" do
  redirect "/login" unless session[:logged_in]

  @users = User.where(id: params[:user_id])
  @users.each do |user|
    # TODO: delete user
  end

  @offset = 0
  @limit = User.count

  if @limit > 10
    @limit = 10
  end

  @users = User.limit(@limit).offset(@offset).all

  erb :manageAccounts
end

post "/accounts/next" do
  @offset = @offset + 1;
end