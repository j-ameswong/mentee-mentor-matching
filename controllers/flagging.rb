get "/flagging" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  @unflagged = authentication.where(flagged: false).all
  erb :flagging
end