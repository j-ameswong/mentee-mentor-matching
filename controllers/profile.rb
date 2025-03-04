post "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User[session[:username]]
  erb :profile

  redirect "/profile?edit=0" if params[:edit] == 1
  redirect "/profile?edit=1" if params[:edit] == 0
end

get "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User[session[:id]]
  erb :profile
end

get "/profile/profile_pic" do
  redirect "/" unless session[:logged_in]
  @user = User[session[:id]]
  content_type 'image/png'
  
  @user.profile_pic
end