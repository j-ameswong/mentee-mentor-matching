get "/flagging" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  @unflagged = users.all
  erb :flagging
end