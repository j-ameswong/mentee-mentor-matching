post "/login" do
  @error = "Username/Password combination incorrect"
  @username = params.fetch("university_email", "").strip
  @user = User.first(university_email: @username)

  @form_was_submitted = false if params[:university_email] == "" || params[:password] == ""

  #puts params
  if !@form_was_submitted
    puts "test"
    @username_error = "Please enter your username" if params[:university_email] == ""
    @password_error = "Please enter your password" if params[:password] == ""
    redirect "/login"
  end



  unless user.nil?
    success_decrypt = user.login(params)

    unless success_decrypt.nil?
      session[:logged_in] = true
      session[:username] = @username
      redirect "/"
    end
  end

  redirect "/login"
end