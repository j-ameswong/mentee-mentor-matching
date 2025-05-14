require "csv"

post "/profile/edit" do
  # TODO: Only matched pairs can view each other's details, unless admin or themself
  redirect "/" unless session[:logged_in]
  @edited_user = session[:user]
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

  # checking if the profile picture is valid
  if params[:profile_pic] && params[:profile_pic][:tempfile] && !invalid_pic?(params[:profile_pic])
    # take the file extension from the uploaded file
    file_ext = params[:profile_pic][:filename].split('.').last
    # create path to save the file
    path = "public/images/user/#{@edited_user.id}.#{file_ext}"
    File.open(path, "wb") do |f|
      # write the file to the path
      f.write(params[:profile_pic][:tempfile].read)
      puts "File saved to #{path}"
      # update the profile picture in the database
      @profile = Profile.where(:user_id => @edited_user.id).first
      @profile.profile_picture = "#{@edited_user.id}.#{file_ext}"
      @profile.save
      puts @profile.inspect
    end
  end

  @all_good = true

  # Checking all fields are valid characters
  if invalid_pic?(params[:profile_pic]) || !valid_input?(params[:first_name]) || !valid_input?(params[:last_name]) || !valid_email?(params[:email]) || html_unsafe?(params[:bio_brief]) || html_unsafe?(params[:bio_detailed])
    @all_good = false
  end

  puts "@all_good: #{@all_good}"

  @edited_user.role = params[:role] if params[:role]

  # Only update the profile if params are valid
  if @all_good
    @edited_user.profile.update(params)
  else
    inv = "is invalid"
    @edited_user.errors.add(:profile_pic, invalid_pic?(params[:profile_pic])) if invalid_pic?(params[:profile_pic])
    @edited_user.errors.add(:first_name, inv) unless valid_input?(params[:first_name])
    @edited_user.errors.add(:last_name, inv) unless valid_input?(params[:last_name])
    @edited_user.errors.add(:email, inv) unless valid_email?(params[:email])
    @edited_user.errors.add(:bio_brief, inv) if html_unsafe?(params[:bio_brief])
    @edited_user.errors.add(:bio_detailed, inv) if html_unsafe?(params[:bio_detailed])
    @err_str = @edited_user.errors.inspect.tr(':{"[]}', '')
    @err_str = @err_str.tr('_', ' ')
    puts " #{@err_str}"
  end
  @edited_user.mentor_profile.update(params.merge(:availability => true)) if @edited_user.mentor?
  # after editing profile for the first time, mentee is now open to matching
  @edited_user.mentee_profile.update(:availability => true) if @edited_user.mentee?
  # DEBUG: params[:user_languages].each {|x| puts x}
  UserLanguage.create!(params)
  UserExpertise.create!(params)

  if @edited_user.errors.empty?
    @edited_user.save
    @edited_user.profile.save
    @edited_user.mentor_profile.save if @edited_user.mentor?
    @edited_user.mentee_profile.save if @edited_user.mentee?
    puts params

    redirect "/profile?id=#{@edited_user.id}"
  end

  erb :profileEdit
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

  @edited_user.authentication.update(:first_time_login => false)
  @edited_user.authentication.save

  erb :profileEdit
end