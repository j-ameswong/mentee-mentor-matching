get "/login" do
  redirect "/" if session[:logged_in]
  erb :login
end

post "/login" do
  @error = "Username/Password combination incorrect"
  @username = params.fetch("university_email", "").strip
  user = User.first(university_email: @username)

  unless user.nil?
    data = user.login(params)

    unless data.nil?
      session[:logged_in] = true
      session[:username] = username
      session[:data] = data
      redirect "/"
    end
  end

  erb :login
end

=begin
post "/login" do
  @username = params.fetch("email-address", "")
  @password = params.fetch("password", "")
  @error = nil

  if @username == "johnsmith@email.com" && @password == "pass"
    session["logged_in"] = true
    redirect "/"
  else
    @error = "Username/Password combination incorrect"
  end

  erb :login
end
=end