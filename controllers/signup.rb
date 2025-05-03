get "/signup" do
  redirect "/" if session[:logged_in]
  erb :signup
end

post "/signup" do
  @user = User.new
  @params = h(params)
  puts @params

  # @user.signup returns true if signup successful,
  # else load page and display errors
  if
    @user.signup(@params)
    redirect "/"
  else
    erb :signup
  end
end


