require 'sequel'
require 'digest'
# require 'date'
# require 'time_difference'
require_relative '../db/db'
Dir["#{__dir__}/*.rb"].each do |file|
  require file
end

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
    errors.add(:role, 'cannot be empty') if role.nil? || role.empty?
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

  def signup(params)
    self.username = params.fetch(:username, "").strip
    self.email = params.fetch(:email, "").strip
    self.role = params.fetch(:role)

    Profile.create(user_id: self.id)
    self.profile.date_of_birth = params.fetch(:date_of_birth, "")

    self.first_name = params.fetch("first_name", "").strip
    self.first_name[0] = first_name[0].upcase if first_name.length > 0

    self.last_name = params.fetch("last_name", "").strip
    self.last_name[0] = last_name[0].upcase if last_name.length > 0

    self.acc_type = params.fetch("acc_type", "")

    # gen_uid produces a random id
    self.id = gen_uid

    self.year_of_study = params.fetch("year_of_study")

    self.username = params.fetch("username", "").strip.downcase

    terms = params.fetch("terms", "").strip

    password = params.fetch("password", "").strip
    confirm_password = params.fetch("confirm_password", "").strip

    self.approved = "false"
    self.first_time_login = "true"

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

    # Set up AES for encryption.
    aes = OpenSSL::Cipher.new('AES-128-CBC').encrypt
    # Generate a random IV.
    self.iv = Sequel.blob(aes.random_iv)
    # Generate a random salt.
    self.salt = Sequel.blob(OpenSSL::Random.random_bytes(16))
    # Get the key from the password and salt.
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt, 20_000, 16)
    # Encrypt the data
    self.data_crypt = Sequel.blob(aes.update(username) + aes.final)

    if iv.nil? || iv.empty? || salt.nil? || salt.empty? || data_crypt.nil? || data_crypt.empty?
      errors.add("encryption", "Encryption error")
    end

    if self.errors.nil?
      puts "Critical error! User.errors is nil"
    end
    return false unless self.errors.empty?

    true
  end
end

