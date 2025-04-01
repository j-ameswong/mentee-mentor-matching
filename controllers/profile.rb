require "csv"

post "/profile/edit" do
  redirect "/" unless session[:logged_in]
  # DEBUG: puts params
  @edited_user = User.first(id: params[:id].to_i)
  redirect "/profile" if @edited_user.nil?

  # The code here is to update the user's profile, if field is blank
  # then it will remain the same, else it will update the field
  params.merge!(:user_id => @edited_user.id)

  @edited_user.role = params[:role] if params[:role]
  @edited_user.profile.update!(params)
  @edited_user.mentor_profile.update!(params.merge!(:availability => true)) if @edited_user.mentor?
  # DEBUG: params[:user_languages].each {|x| puts x}
  UserLanguage.create!(params)



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
  @languages = Language.all

  @edited_user = User.first(id: params[:id].to_i) unless params[:id].nil?
  @edited_user = session[:user] if @edited_user.nil?

  @edited_user.authentication.update!(:first_time_login => false)
  @edited_user.authentication.save

  erb :profileEdit
end