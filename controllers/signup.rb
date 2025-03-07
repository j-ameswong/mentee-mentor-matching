get "/signup" do
  redirect "/" if session[:logged_in]
  erb :signup
end

post "/signup" do
  @error = "Please correct the information below"
  @user = User.new

  if @user.signup(params)
    @user.save
    redirect "/"
  end

  erb :signup
end
