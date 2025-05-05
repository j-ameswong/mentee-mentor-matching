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

  # Checking all fields for invalid characters
  @all_good = true
  @fname_bad = params[:first_name].match?(/\A[a-zA-Z0-9]*\z/).nil?
  puts @fname_bad
  @lname_bad = params[:last_name].match?(/\A[a-zA-Z0-9]*\z/).nil?
  puts @lname_bad
  @email_bad = params[:email].match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i).nil?
  puts @email_bad
  @brief_bad = params[:bio_brief].match?(/\A[-a-zA-Z0-9 "'!?;:,+@()]*\z/).nil?
  puts @brief_bad
  @bio_bad = params[:bio_detailed].match?(/\A[-a-zA-Z0-9 "'!?;:,+@()]*\z/).nil?
  puts @bio_bad

  if @fname_bad || @lname_bad || @email_bad || @brief_bad || @bio_bad
    @all_good = false
  end

  puts "@all_good: #{@all_good}"
  @edited_user.role = params[:role] if params[:role]

  # Only update the profile if params are valid
  if @all_good
    @edited_user.profile.update!(params)
  else
    @edited_user.errors.add(:first_name, "Invalid first name") if @fname_bad
    @edited_user.errors.add(:last_name, "Invalid last name") if @lname_bad
    @edited_user.errors.add(:email, "Invalid email") if @email_bad
    @edited_user.errors.add(:bio_brief, "Invalid bio brief") if @brief_bad
    @edited_user.errors.add(:bio_detailed, "Invalid bio detailed") if @bio_bad
  end
  @edited_user.mentor_profile.update!(params) if @edited_user.mentor?
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

  @edited_user = User.first(id: params[:id].to_i) unless params[:id].nil?
  @edited_user = session[:user] if @edited_user.nil?

  @edited_user.authentication.update!(:first_time_login => false)
  @edited_user.authentication.save

  erb :profileEdit
end