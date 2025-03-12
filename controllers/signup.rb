get "/signup" do
  redirect "/" if session[:logged_in]
  erb :signup
end

post "/signup" do
  @user = User.new
  puts params

  # @user.signup returns true if signup successful,
  # else load page and display errors
  if @user.signup(params)
    @user.save
    redirect "/"
  else
    @error = "Please correct the information below"
    erb :signup
  end
end


