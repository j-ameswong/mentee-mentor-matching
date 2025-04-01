get "/signup/admin" do
  redirect "/" if session[:logged_in]
  erb :signupAdmin
end

post "/signup/admin" do
  @user = User.new
  paramss = params.merge(:username => params[:email].split("@")[0], :role => "admin")

  if @user.signup(paramss)
    redirect "/"
  end

  erb :signupAdmin
end
