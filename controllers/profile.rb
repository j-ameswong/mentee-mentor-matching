require "csv"

post "/profile/edit" do
  redirect "/" unless session[:logged_in]
  puts params
  @edited_user = User.first(id: params[:id].to_i)
  redirect "/profile" if @edited_user.nil?

  # The code here is to update the user's profile, if field is blank
  # then it will remain the same, else it will update the field
  # TODO: probably can delete all below, and use Profile.update!(params)
  #@edited_user.email = params.fetch("email").strip unless params[:email].nil?
  #@edited_user.date_of_birth = params.fetch("date_of_birth").strip unless params[:date_of_birth].nil?
  #@edited_user.first_name = params.fetch("first_name").strip unless params[:first_name].nil?
  #@edited_user.last_name = params.fetch("last_name").strip unless params[:last_name].nil?
  #@edited_user.role = params.fetch("role", @edited_user.role).strip unless params[:role].nil?
  #@edited_user.year_of_study = params["year_of_study"].strip unless params[:year_of_study].nil?
  #@edited_user.languages = params.fetch("languages").strip unless params[:languages].nil?
  #@edited_user.nationality = params.fetch("nationality") unless params[:nationality].nil?
  #@edited_user.description = params.fetch("description").strip unless params[:description].nil?

  # Check if tempfile exists
  if params[:profile_pic] && params[:profile_pic][:tempfile]
    @img_data = params[:profile_pic][:tempfile].read
    puts "Length of img_data: #{@img_data.length}"
    File.open("./public/images/user/#{@edited_user.profile.return_hash(@edited_user.email)}", "wb") do |f|
      f.write(@img_data)
    end
    @edited_user.profile.profile_pic = @edited_user.profile.return_hash(@edited_user.email)
  end

  if @edited_user.errors.empty?
    @edited_user.save
    redirect "/profile?id=#{@edited_user.id}"
  else
    erb :profileedit
  end
end

post "/profile" do
  redirect "/" unless session[:logged_in]
  redirect "/profile/edit?id=#{params[:id]}"
end

get "/profile" do
  redirect "/" unless session[:logged_in]

  @viewed_user = User.first(id: params[:id].to_i) unless params[:id].nil?
  @viewed_user = session[:user] if @viewed_user.nil?

  @data = CSV.table("./public/resources/country.csv")
  @countries = @data[:value]

  erb :profile
end

get "/profile/get_image" do
  @user = session[:user]
  content_type 'image/*'

  params[:profile_pic][:tempfile].read if params[:profile_pic] && params[:profile_pic][:tempfile]
end

get "/profile/edit" do
  redirect "/" unless session[:logged_in]

  if params[:id].nil?
    @edited_user = session[:user]
  else
    @edited_user = User.first(id: params[:id].to_i)
    puts @edited_user.inspect
  end

  redirect "/profile" if @edited_user.nil?

  @edited_user.authentication.first_time_login = false if @edited_user.authentication.first_time_login
  @edited_user.authentication.save

  @data = CSV.table("./public/resources/country.csv")
  @countries = @data[:value]

  erb :profileedit
end