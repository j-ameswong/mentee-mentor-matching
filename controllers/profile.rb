require "csv"

post "/profile/edit" do
  # TODO: Only matched pairs can view each other's details, unless admin or themself
  redirect "/" unless session[:logged_in]
  @edited_user = User.first(id: params[:id].to_i)
  redirect "/profile" if @edited_user.nil?

  # The code here is to update the user's profile, if field is blank
  # then it will remain the same, else it will update the field
  params.merge!(:user_id => @edited_user.id)

  # Sanitising inputs
  params[:first_name] = h(params[:first_name].strip) if params[:first_name]
  params[:last_name] = h(params[:last_name].strip) if params[:last_name]
  params[:email] = h(params[:email].strip) if params[:email]
  params[:bio_brief] = h(params[:bio_brief].strip) if params[:bio_brief]
  params[:bio_detailed] = params[:bio_detailed].strip if params[:bio_detailed]

  @all_good = true

  # Checking all fields are valid characters
  if !valid_input?(params[:first_name]) || !valid_input?(params[:last_name]) || !valid_email?(params[:email]) || html_unsafe?(params[:bio_brief]) || html_unsafe?(params[:bio_detailed])
    @all_good = false
  end

  puts "@all_good: #{@all_good}"
  @edited_user.role = params[:role] if params[:role]
<<<<<<< HEAD

  # Only update the profile if params are valid
  if @all_good
    @edited_user.profile.update!(params)
  else
    @edited_user.errors.add(:first_name, "Invalid first name") unless valid_input?(params[:first_name])
    @edited_user.errors.add(:last_name, "Invalid last name") unless valid_input?(params[:last_name])
    @edited_user.errors.add(:email, "Invalid email") unless valid_email?(params[:email])
    @edited_user.errors.add(:bio_brief, "Invalid bio brief") if html_unsafe?(params[:bio_brief])
    @edited_user.errors.add(:bio_detailed, "Invalid bio detailed") if html_unsafe?(params[:bio_detailed])
  end
  @edited_user.mentor_profile.update!(params) if @edited_user.mentor?
=======
  @edited_user.profile.update!(params)
  @edited_user.mentor_profile.update!(params.merge!(:availability => true)) if @edited_user.mentor?
>>>>>>> 27-matching
  # DEBUG: params[:user_languages].each {|x| puts x}
  UserLanguage.create!(params)
  UserExpertise.create!(params)

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

  # TODO: Only matched pairs can view each other's details, unless admin or themself
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
  @expertises = Expertise.all

  # @expertises.each { |e| puts e.category }

  @edited_user = User.first(id: params[:id].to_i) unless params[:id].nil?
  @edited_user = session[:user] if @edited_user.nil?

  @edited_user.authentication.update!(:first_time_login => false)
  @edited_user.authentication.save

  erb :profileEdit
end