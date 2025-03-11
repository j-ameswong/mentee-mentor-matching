require "csv"

post "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User.first(university_email: session[:username])
  puts params

  if params[:edit] == "1" #&& params[:id] == @user.id
    # The code here is to update the user's profile, if field is blank 
    # then it will remain the same, else it will update the field

    # TODO: create profile pic variable
    @user.university_email = params.fetch("university_email").strip unless params[:university_email].nil?
    @user.date_of_birth = params.fetch("date_of_birth").strip unless params[:date_of_birth].nil?
    @user.first_name = params.fetch("first_name").strip unless params[:first_name].nil?
    @user.last_name = params.fetch("last_name").strip unless params[:last_name].nil?
    @user.acc_type = params.fetch("acc_type", @user.acc_type).strip unless params[:acc_type].nil?
    
    if !params["year_of_study_year"].nil? && !params["year_of_study_degree"].nil?
      @user.year_of_study = (params.fetch("year_of_study_year") + " " + params.fetch("year_of_study_degree"))
    end

    @user.languages = params.fetch("languages").strip unless params[:languages].nil?
    #@user.profile_pic = Sequel.blob(params.fetch("profile_pic")[:tempfile].read) if params[:profile_pic] && params[:profile_pic][:tempfile]
    @user.nationality = params.fetch("nationality") unless params[:nationality].nil?
    
    #Restrict the size of the profile pic to 5Mb
    #Add errror message is size exceeds 5Mb
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
  @user = User.first(university_email: session[:username])

  @data = CSV.table("./public/resources/country.csv")
  @countries = @data[:value]

  erb :profile
end

get "/profile/get_image" do
  @user = User.first(university_email: session[:username])
  content_type 'image/*'

  #puts "We're trying to get the image"
  params[:profile_pic][:tempfile].read if params[:profile_pic] && params[:profile_pic][:tempfile]
end