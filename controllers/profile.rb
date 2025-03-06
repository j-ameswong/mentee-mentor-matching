require "csv"

post "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User.first(university_email: session[:username])
  puts params

  if params[:edit].to_s == "1"
    # The code here is to update the user's profile, if field is blank 
    # then it will remain the same, else it will update the field
    @user.university_email = params.fetch("university_email").strip unless params.fetch("university_email").nil?
    @user.date_of_birth = params.fetch("date_of_birth").strip unless params.fetch("date_of_birth").nil?
    @user.first_name = params.fetch("first_name").strip unless params.fetch("first_name").nil?
    @user.last_name = params.fetch("last_name").strip unless params.fetch("last_name").nil?
    #@user.acc_type = params.fetch("acc_type", @user.acc_type).strip unless params.fetch("acc_type").nil?
    @user.year_of_study = (params.fetch("year_of_study_year").strip + " " + params.fetch("year_of_study_degree"))
    @user.languages = params.fetch("languages").strip unless params.fetch("languages").nil?
    @user.profile_pic = Sequel.blob(params.fetch("profile_pic")[:tempfile].read) unless params.fetch("profile_pic")[:tempfile].nil?
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

  @data = CSV.table("./public/resources/country.csv")
  @countries = @data[:value]

  erb :profile
end

get "/profile/get_image" do
  redirect "/" unless session[:logged_in]
  @user = User.first(university_email: session[:username])
  content_type 'image/png'

  puts "We're trying to get the image"
  @user.profile_pic unless @user.profile_pic.nil?
end