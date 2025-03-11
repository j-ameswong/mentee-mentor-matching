require "csv"

post "/profile" do
  redirect "/" unless session[:logged_in]
  #TODO: refactoring instead of using edit param, just make view via /profile/edit
  # also note: i'm an idiot frfr

  # TODO 2: make viewing other people's profile possible for future matching features
  @user = session[:user]
  puts params

  if params[:edit] == "1" #&& params[:id] == @user.id
    # The code here is to update the user's profile, if field is blank 
    # then it will remain the same, else it will update the field
    @user.university_email = params.fetch("university_email").strip unless params[:university_email].nil?
    @user.date_of_birth = params.fetch("date_of_birth").strip unless params[:date_of_birth].nil?
    @user.first_name = params.fetch("first_name").strip unless params[:first_name].nil?
    @user.last_name = params.fetch("last_name").strip unless params[:last_name].nil?
    @user.acc_type = params.fetch("acc_type", @user.acc_type).strip unless params[:acc_type].nil?
    @user.year_of_study = params["year_of_study"].strip unless params[:year_of_study].nil?
    @user.languages = params.fetch("languages").strip unless params[:languages].nil?
    # Alternative method, storing directly in DB with BLOB type data
    # @user.profile_pic = Sequel.blob(params.fetch("profile_pic")[:tempfile].read) if params[:profile_pic] && params[:profile_pic][:tempfile]
    @user.nationality = params.fetch("nationality") unless params[:nationality].nil?

    # Check if tempfile exists
    if params[:profile_pic] && params[:profile_pic][:tempfile]
      @imgdata = params[:profile_pic][:tempfile].read 
      puts "Length of imgdata: #{@imgdata.length}" 
      File.open("./public/images/user/#{@user.img_hash(@user.university_email)}", "wb") do |f|
        f.write(@imgdata)
      end
      @user.profile_pic = @user.img_hash(@user.university_email)
    end
    @user.save
    redirect "/profile?edit=0"
  elsif params[:edit] == "0" #&& params[:id] == @user.id
    redirect "/profile?edit=1"
  else
    redirect "/profile"
  end
  erb :profile
end

get "/profile" do
  redirect "/" unless session[:logged_in]

  @user = session[:user]
  @user.first_time_login = "false" if @user.first_time_login == "true"
  @user.save

  @data = CSV.table("./public/resources/country.csv")
  @countries = @data[:value]

  erb :profile
end

get "/profile/get_image" do
  @user = session[:user]
  content_type 'image/*'

  #puts "We're trying to get the image"
  params[:profile_pic][:tempfile].read if params[:profile_pic] && params[:profile_pic][:tempfile]
end