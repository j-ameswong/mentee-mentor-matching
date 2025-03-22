get "/login" do
  redirect "/" if session[:logged_in]
  erb :login
end

# redirects should only happen if successful login, to preserve @user instance and its errors
post "/login" do
  # typed field, could be username or email
  field = params.fetch("field", "").strip.downcase
  @user = User.find_user(field)

  if field.empty?
    @user.errors.add "field", "Can't be blank"
  elsif @user.login({"password"=>params.fetch("password", "")})
    # password errors are added when @user.login is called
    session[:logged_in] = true
    session[:user] = @user

    # if first time logging in, prompt to edit profile if mentee, or change password if admin else go home page
    if @user.first_time_login == "true"
      if @user.acc_type == "admin"
        redirect("/account/changepassword")
      elsif @user.acc_type == "mentee" || @user.acc_type == "mentor"
        redirect("/profile/edit")
      end
    else
      redirect("/")
    end
  end

  erb :login
end