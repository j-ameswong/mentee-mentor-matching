post "/login" do
  @error = "Username/Password combination incorrect"
  @username = params.fetch("university_email", "").strip
  user = User.first(university_email: @username)

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