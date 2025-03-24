get "/signup/admin" do
  redirect "/" if session[:logged_in]
  erb :signupadmin
end

post "/signup/admin" do
  @user = User.new
  email = params.fetch("email", "").strip

  if email.empty? || !User.first(email: email).nil? || !email.include?("@sheffield.ac.uk")
    @user.errors.add "email", "Email field is empty, invalid, or user already exists"
  else
    @user.email = params.fetch("email", "").strip
    @user.id = @user.gen_uid
    @user.username = @user.email[0..-17]
    @user.role = "admin"
    @user.first_time_login = "true"
    @user.approved = "false"
    @user.save
    redirect "/"
  end

  erb :signupadmin
end
