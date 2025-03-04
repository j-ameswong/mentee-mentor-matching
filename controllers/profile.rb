post "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User[session[:username]]
  erb :profile

  if params[:edit] == 1
    @user.university_email = params.fetch("university_email", "").strip
    @user.date_of_birth = params.fetch("date_of_birth", "").strip
    @user.first_name = params.fetch("first_name", "").strip
    @user.last_name = params.fetch("last_name", "").strip
    @user.acc_type = params.fetch("acc_type", "").strip
    @user.profile_pic = params.fetch("profile_pic", "").strip
    @user.save
    redirect "/profile?edit=0" 
  elsif params[:edit] == 0
    redirect "/profile?edit=1"
  end
end

get "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User[session[:id]]
  erb :profile
end

get "/profile/profile_pic" do
  redirect "/" unless session[:logged_in]
  @user = User[session[:id]]
  content_type 'image/*'

  @user.profile_pic
end