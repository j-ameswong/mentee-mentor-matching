get "/login" do
  redirect "/" if session[:logged_in]
  erb :login
end

# redirects should only happen if successful login, to preserve @user instance and its errors
post "/login" do
  # input field, could be username or email
  field = params.fetch("field", "").strip.downcase
  @user = User.find_user(field)

  if @user.authentication && @user.authentication.login(params)
    # password errors are added when @user.login is called
    session[:logged_in] = true
    session[:user] = @user

    # if first time logging in, prompt to edit profile if mentee, or change password if admin else go home page
    if @user.authentication.first_time_login
      if @user.admin?
        redirect("/account/changePassword")
      elsif @user.mentee? || @user.mentor?
        redirect("/profile/edit")
      end
    else
      redirect("/")
    end
  end

  erb :login
end