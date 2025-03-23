require 'sequel'
require 'digest'
require 'date'
require 'openssl'
# require 'time_difference'
require_relative '../db/db'
Dir["#{__dir__}/*.rb"].each do |file|
  require file
end

# TODO: create_user command, rescue ValidationError by doing nothing instead of reloading view
class User < Sequel::Model
  plugin :timestamps, update_on_create: true

  one_to_one :authentication
  one_to_one :profile
  one_to_one :mentor_profile
  one_to_one :mentee_profile

  one_to_many :mentor_matches, class: :Match, key: :mentor_id
  one_to_many :mentee_matches, class: :Match, key: :mentee_id

  one_to_many :user_languages
  one_to_many :user_expertises

  # enum for roles
  ROLES = %w[admin mentor mentee] # fancy way to do a comma separated list

  def validate
    super
    errors.add(:email, 'cannot be empty') if email.nil? || email.empty?
    errors.add(:role, 'must be valid') unless ROLES.include?(role)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    self.role == 'admin'
  end

  def mentor?
    self.role == 'mentor'
  end

  def mentee?
    self.role == 'mentee'
  end

  def find_user(field)
    # either lookup users table by email or username
    Validation.valid_email_address(field) ? user = self.first(email: field) : user = self.first(username: field)

    # basically, if no user found create a user instance, appears in controllers/login.rb
    self.errors.add(:field, "Can't be blank") if user.nil?
    user.nil? ? self.new : user
  end

  def gen_uid
    # generate until return unique 9 digit id
    id = 100000000 + rand(899999999)
    while User.first(id: id) != nil
      id = 100000000 + rand(899999999)
    end
    id
  end

  def signup(params)
    self.id = self.gen_uid
    self.username = params.fetch(:username, "").strip.downcase
    self.email = params.fetch(:email, "").strip.downcase
    self.role = params[:role]

    # profiles table, Profile class, admins dont need profile
    unless self.admin?
      profile = Profile.new
      profile.user_id = self.id
      profile.date_of_birth = params[:date_of_birth]
      profile.first_name = params.fetch(:first_name, "").strip.capitalize
      profile.last_name = params.fetch(:last_name, "").strip.capitalize
      # maybe rescue in profile, add profile errors to user errors, then display like that??
      unless profile.valid?
        puts "Error when writing to profiles: " + profile.errors.full_messages
        self.errors.merge(profile.errors)
      end

      # languages spoken by each user, initialize first then populate in edit profile page
      lang = UserLanguage.new
      lang.user_id = self.id

      # mentor_profiles table, MentorProfile class
      if self.mentor?
        mentor = MentorProfile.new
        mentor.user_id = self.id
        mentor.year_of_study = params[:year_of_study]
        mentor.num_matches = 0
        # @mentor.max_matches <== set in initial edit profile page
        begin
          mentor.save
        rescue Sequel::ValidationError
          puts "Error when writing to mentor_profiles: " + mentor.errors.full_messages
          self.errors.merge(mentor.errors)
        end

        UserExpertise.create(user_id: self.id)
      end

      if self.mentee?
        mentee = MenteeProfile.new
        mentee.user_id = self.id
        mentee.availability = true
        mentee.save
      end
    end

    auth = Authentication.new
    auth.user_id = self.id

    pass = params.fetch(:password, "").strip
    confirm_password = params.fetch(:confirm_password, "").strip

    aes = OpenSSL::Cipher.new('AES-128-CBC').encrypt
    auth.iv = Sequel.blob(aes.random_iv)
    auth.salt = Sequel.blob(OpenSSL::Random.random_bytes(16))
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pass, auth.salt, 20_000, 16)
    auth.data_crypt = Sequel.blob(aes.update(username) + aes.final)

    auth.approved = false # be default false, after admin approval, true
    auth.first_time_login = true

    begin
      auth.save
    rescue Sequel::ValidationError
      puts "Error when writing to authentication: " + auth.errors.full_messages
      self.errors.merge(auth.errors)
    end

    @terms = params.fetch("terms", "").strip

=begin
    if university_email.empty?
      errors.add("email", "Fill in your email address")
    else
      errors.add("email", "Email already taken") unless User.first(university_email: university_email).nil?
      errors.add("email", "Please use your university email") unless university_email.include?("@sheffield.ac.uk")
    end

    errors.add("first_name", "Fill in your first name") if first_name.empty?
    errors.add("last_name", "Fill in your last name") if last_name.empty?
    errors.add("date_of_birth", "Cannot be empty") if date_of_birth.empty?

    errors.add("username", "Username cannot be empty") if username.empty?
    errors.add("username", "Username already exists") unless User.first(username: username).nil?

    errors.add("terms", "Terms must be accepted") if terms.nil? || terms.empty? || terms != "terms_accepted"

    errors.add("role", "First years cannot be mentors") if year_of_study == "1" && acc_type == "mentor"
    errors.add("role", "Only first years can be mentees") if year_of_study != "1" && acc_type == "mentee"

    self.check_password(password, confirm_password)


    if self.errors.nil?
      puts "Critical error! User.errors is nil"
    end
    return false unless self.errors.empty?

    true
 end
=end
  end
end

