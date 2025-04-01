require_relative "../db/db"

class Profile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user
  many_to_one :nationality, key: :id

  def update!(params)
    @role = params[:role] if params.key?(:role)
    self.user_id = params[:user_id] if params.key?(:user_id)
    self.date_of_birth = params.fetch(:date_of_birth, "") if params.key?(:date_of_birth)
    self.first_name = params.fetch(:first_name, "").strip.capitalize if params.key?(:first_name)
    self.last_name = params.fetch(:last_name, "").strip.capitalize if params.key?(:last_name)
    self.nationality_id = params[:nationality] if params.key?(:nationality)
    self.gender = params[:gender] if params.key?(:gender)
    # self.profile_picture = params[:profile_picture] if params.key?(:profile_picture)
    self.bio_brief = params[:bio_brief] if params.key?(:bio_brief)
    self.bio_detailed = params[:bio_detailed] if params.key?(:bio_detailed)
    # Check if tempfile exists
    if params[:profile_pic] && params[:profile_pic][:tempfile]
      @img_data = params[:profile_pic][:tempfile].read
      # puts "Length of img_data: #{@img_data.length}"
      File.open(File.expand_path("../public/images/user/#{return_hash(self.user.email)}", __dir__), "wb") { |f| f.write(@img_data) }
      self.profile_picture = return_hash(self.user.email)
    end
  end

  def age
    dob = DateTime.parse(date_of_birth.to_s)
    now = DateTime.now
    # return age
    TimeDifference.between(dob, now).in_years.to_i
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def return_hash(value)
    Digest::SHA256.hexdigest(value)
  end

  def save_profile_picture(params)
    # TODO: this function and validation as well
  end

  def validate
    super

    errors.add(:user_id, "cannot be empty") if user_id.nil?
    unless date_of_birth.nil?
      errors.add(:date_of_birth, "is invalid") if date_of_birth == "" || !str_yyyy_mm_dd_date?(date_of_birth)
    end
    errors.add(:first_name, "is invalid") unless valid_input?(first_name)
    errors.add(:last_name, "is invalid") unless valid_input?(last_name)
    unless gender.nil?
      errors.add(:gender, "is required") if gender.empty?
      errors.add(:gender, "invalid input") unless valid_input?(gender)
    end
    errors.add(:bio_brief, "is too long") if !bio_brief.nil? && bio_brief.length > 255
    unless bio_detailed.nil?
      # TODO: once css is fixed, uncomment
      #errors.add(:bio_detailed, "is too short") if bio_detailed.length < 255
      errors.add(:bio_detailed, "is too long") if bio_detailed.length > 2200
    end
  end
end

class MentorProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def update!(params)
    params.key?(:role) ? @role = params[:role] : @role = "mentor"
    self.user_id = params[:user_id] if params.key?(:user_id)
    self.year_of_study = params[:year_of_study] if params.key?(:year_of_study)
    self.num_matches = 0 if self.num_matches.nil?
    self.num_matches = params[:num_matches] if params.key?(:num_matches)
    self.max_matches = 3 if self.max_matches.nil?
    self.max_matches = params[:max_matches] if params.key?(:max_matches)
    params.key?(:availability) ? self.availability = params[:availability] : self.availability = false
    self.availability = false if self.num_matches >= self.max_matches
  end

  def validate
    super
    errors.add(:user_id, "cannot be empty") if user_id.nil?
    errors.add(:year_of_study, "cannot be empty") if year_of_study.nil?
    errors.add(:role, "first years cannot be mentors") if year_of_study && year_of_study.to_i < 2
    errors.add(:num_matches, "cannot exceed max_matches set") if num_matches > max_matches
    errors.add(:max_matches, "cannot exceed maximum allowed") if max_matches > 3
    errors.add(:user_id, "must belong to a mentor") unless @role.nil? || @role == "mentor"
  end

  def available
    num_matches < max_matches
  end

  def experience
    # return current date - date of first match created, fetch from matches table
  end


end

class MenteeProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def update!(params)
    params.key?(:role) ? @role = params[:role] : @role = "mentee"
    params.key?(:year_of_study) ? @year_of_study = params[:year_of_study] : @year_of_study = 1

    self.user_id = params[:user_id] if params.key?(:user_id)
    params.key?(:availability) ? params[:availability] : self.availability = true
  end

  def validate
    super
    errors.add(:user_id, "cannot be empty") if user_id.nil?
    errors.add(:user_id, "must belong to a mentee") unless @role == "mentee"
    errors.add(:availability, "status must exist") if availability.nil?
    errors.add(:year_of_study, "cannot be empty") if @year_of_study.nil?
    errors.add(:role, "only first years can be mentees") if @year_of_study && @year_of_study.to_i > 1
  end

  def available?
    availability
  end
end
