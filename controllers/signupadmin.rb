get "/signupadmin" do
  redirect "/" if session[:logged_in]
  erb :signupadmin
end

post "/signupadmin" do
  @error = "Please correct the information below"
  @user = User.new
  @email = params.fetch("university_email", "").strip

  if @email.empty? || !User.first(university_email: @email).nil?
    @user.errors.add "email", "Email field is empty or user already exists"
    #puts params, @user.errors
  else
    @user.university_email = params.fetch("university_email", "").strip
    @user.id = @user.gen_uid()
    @user.acc_type = "admin"
    @user.approved = "false"
    @user.save
  end

  erb :signupadmin
end
