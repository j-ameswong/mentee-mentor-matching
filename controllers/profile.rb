require "csv"

post "/profile/edit" do
  redirect "/" unless session[:logged_in]
  puts params
  @edited_user = User.first(id: params[:id].to_i)
  redirect "/profile" if @edited_user.nil?

  # The code here is to update the user's profile, if field is blank
  # then it will remain the same, else it will update the field
  @edited_user.role = params[:role] if params[:role]
  @edited_user.profile.update!(params)
  @edited_user.mentor_profile.update!(params) if @edited_user.mentor?
  params[:languages].split(",")[0..-2].each do |lang|
    lang = Language.first(language_name: lang)
    next unless lang
    user_lang = UserLanguage.first(user_id: @edited_user.id, language_id: lang.id)
    next if user_lang


    user_lang = UserLanguage.new
    user_lang.user_id = @edited_user.id

    lang_id = Language.first(language_name: lang)
    puts lang_id.inspect
    # user_lang.language_id = lang_id.id unless lang_id.nil?
    #puts user_lang.inspect
    #user_lang.save
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
    @edited_user.mentor_profile.save if @edited_user.mentor?
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