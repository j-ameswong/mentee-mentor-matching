get "/signup/admin" do
  redirect "/" if session[:logged_in]
  erb :signupadmin
end

post "/signup/admin" do
  @user = User.new
  email = params.fetch("university_email", "").strip

  if email.empty? || !User.first(university_email: email).nil? || !email.include?("@sheffield.ac.uk")
    @user.errors.add "email", "Email field is empty, invalid, or user already exists"
  else
    @user.university_email = params.fetch("university_email", "").strip
    @user.id = @user.gen_uid
    @user.username = @user.university_email[0..-17]
    @user.acc_type = "admin"
    @user.first_time_login = "true"
    @user.approved = "false"
    @user.save
    redirect "/"
  end

  erb :signupadmin
end
