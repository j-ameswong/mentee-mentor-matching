require_relative '../models/user'

get "/login" do
  redirect "/" if session[:logged_in]
  erb :login
end

# redirects should only happen if successful login, to preserve @user instance and its errors
post "/login" do
  email = params.fetch("university_email", "").strip
  user = User.first(university_email: email)
  if user.nil?
    @user = User.new
  else
    @user = user
  end

  if email.empty?
    @user.errors.add "email", "An email is required"
  elsif user.nil?
    @user.errors.add "email", "Email was incorrect or does not exist"
  elsif @user.login({"password"=>params.fetch("password", "")})
    # password errors are added when @user.login is called
    session[:logged_in] = true
    session[:user] = @user
    # if first time logging in, prompt to edit profile if mentee, or change password if admin else go home page
    if @user.first_time_login == "true"
      if @user.acc_type == "admin"
        redirect("/account/changepassword")
      elsif @user.acc_type == "mentee" || @user.acc_type == "mentor"
        redirect("/profile")
      end
    else
      redirect("/")
    end
  else
    erb :login
  end

  erb :login unless @user.errors.empty?
end