require "csv"

post "/profile/edit" do
  redirect "/" unless session[:logged_in]
  puts params
  @edited_user = User.first(id: params[:id].to_i)
  redirect "/profile" if @edited_user.nil?

  # The code here is to update the user's profile, if field is blank
  # then it will remain the same, else it will update the field
  @edited_user.update!(params)
  @edited_user.profile.update!(params)
  @edited_user.mentor_profile.update!(params) if @edited_user.mentor?
  params[:temp_csv].split(",").each do |lang|
    user_lang = @edited_user.user_languages.new
    user_lang.user_id = @edited_user.id
    user_lang.language_id = Language.first(language_name: lang).id
    user_lang.save
  end

  # Check if tempfile exists
  if params[:profile_pic] && params[:profile_pic][:tempfile]
    @img_data = params[:profile_pic][:tempfile].read
    # puts "Length of img_data: #{@img_data.length}"
    File.open(File.expand_path("../public/images/user/#{@edited_user.profile.return_hash(@edited_user.email)}", __dir__), "wb") do |f|
      f.write(@img_data)
    end
    @edited_user.profile.profile_picture = @edited_user.profile.return_hash(@edited_user.email)
  end

  if @edited_user.errors.empty?
    @edited_user.save
    @edited_user.profile.save
    @edited_user.mentor_profile.save
    redirect "/profile?id=#{@edited_user.id}"
  else
    erb :profileEdit
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

  erb :profile
end

get "/profile/get_image" do
  @user = session[:user]
  content_type 'image/*'

  params[:profile_pic][:tempfile].read if params[:profile_pic] && params[:profile_pic][:tempfile]
end

get "/profile/edit" do
  redirect "/" unless session[:logged_in]

  @edited_user = User.first(id: params[:id].to_i) unless params[:id].nil?
  @edited_user = session[:user] if @edited_user.nil?

  @edited_user.authentication.update!(:first_time_login => false)
  @edited_user.authentication.save

  erb :profileEdit
end