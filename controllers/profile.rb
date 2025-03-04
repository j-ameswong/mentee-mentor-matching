post "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User.first(university_email: session[:username])
  puts params

  if params[:edit].to_s == "0"
    @user.university_email = params.fetch("university_email", @user.university_email).strip
    @user.date_of_birth = params.fetch("date_of_birth", @user.date_of_birth).strip
    @user.first_name = params.fetch("first_name", @user.first_name).strip
    @user.last_name = params.fetch("last_name", @user.last_name).strip
    @user.acc_type = params.fetch("acc_type", @user.acc_type).strip
    @user.profile_pic = params.fetch("profile_pic", @user.profile_pic).nil? ? "" : params.fetch("profile_pic", @user.profile_pic).strip
    @user.save
    redirect "/profile?edit=0"
  else
    redirect "/profile?edit=1"
  end

  erb :profile
end

get "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User.first(university_email: session[:username])

  erb :profile
end

get "/profile/get_image" do
  redirect "/" unless session[:logged_in]
  @user = User.first(university_email: session[:username])
  content_type 'image/png'

  puts "We're trying to get the image"
  puts @user.profile_pic
  @user.profile_pic
end