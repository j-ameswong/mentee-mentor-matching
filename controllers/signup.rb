get "/signup" do
  redirect "/" if session[:logged_in]
  erb :signup
end

post "/signup" do
  @user = User.new
  puts params

  # @user.signup returns true if signup successful,
  # else load page and display errors
  begin
    @user.signup(params)
    redirect "/"
  rescue
    erb :signup
  end
end


