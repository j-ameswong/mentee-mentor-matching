post "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User.first(university_email: session[:username])
  puts params

  # The form has :edit set to the opposite of its current state, i.e.
  # if it is 0, it will be set to 1, and vice versa
  if params[:edit].to_s == "0"
    # The code here is to update the user's profile, if field is blank 
    # then it will remain the same, else it will update the field
    @user.university_email = params.fetch("university_email", @user.university_email).nil? ? "" : params.fetch("university_email", @user.university_email).strip
    @user.date_of_birth = params.fetch("date_of_birth", @user.date_of_birth).nil? ? "" : params.fetch("date_of_birth", @user.date_of_birth).strip
    @user.first_name = params.fetch("first_name", @user.first_name).nil? ? "" : params.fetch("first_name", @user.first_name).strip
    @user.last_name = params.fetch("last_name", @user.last_name).nil? ? "" : params.fetch("last_name", @user.last_name).strip
    @user.acc_type = params.fetch("acc_type", @user.acc_type).nil? ? "" : params.fetch("acc_type", @user.acc_type).strip
    @user.year_of_study = params.fetch("year_of_study", @user.year_of_study).nil? ? "" : params.fetch("year_of_study", @user.year_of_study).strip
    @user.profile_pic = params.fetch("profile_pic", @user.profile_pic).nil? ? "" : params.fetch("profile_pic", @user.profile_pic).strip
    @user.languages = params.fetch("languages", @user.languages).nil? ? "" : params.fetch("languages", @user.languages).strip
    @year_of_study = params.fetch("year_of_study_year") + " " + params.fetch("year_of_study_degree")
    @user.year_of_study = @year_of_study
    puts "Year of Study is: " + @year_of_study
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