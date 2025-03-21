require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'

# Specify user table, by default it downcases User and adds an s to the end
class User < Sequel::Model(DB)
  def signup(params)
    self.university_email = params.fetch("university_email", "").strip

    self.date_of_birth = params.fetch("date_of_birth", "")

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

  def login(params)
    password = params.fetch("password", "").strip
    # temp solution to fix admin attempting to sign in before approval
    if self.iv.nil? || self.salt.nil? || self.data_crypt.nil?
      errors.add("password", "Password has not been set by admin, please contact admin")
    else
      # Set up AES for decryption.
      aes = OpenSSL::Cipher.new('AES-128-CBC').decrypt

      # Set the IV.
      aes.iv = self.iv

      # Get the key from the password and salt.
      aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, self.salt, 20_000, 16)

      # Try to decrypt the data.
      begin
        aes.update(self.data_crypt) + aes.final
      rescue OpenSSL::Cipher::CipherError
        errors.add("password", "Password was incorrect")
      end
    end

    errors.add("approval", "Approval has not been granted by admin yet, please try again later") if self.approved != "true"
    return false unless errors.empty?
    true
  end

  def gen_uid
    # generate and return unique id
    idd = 100000000 + rand(899999999)
    while User.first(id: idd) != nil
      idd = 100000000 + rand(899999999)
    end

    idd
  end

  def age(date_of_birth)
    dob = DateTime.parse(date_of_birth)
    now = DateTime.now
    # return age
    TimeDifference.between(dob, now).in_years.to_i
  end
  
  def img_hash(username)
    Digest::SHA256.hexdigest(username)
  end

  # function useful for hashing and storing temporary password for admin
  def hash_pass(password)
    # Set up AES for encryption.
    aes = OpenSSL::Cipher.new('AES-128-CBC').encrypt

    # Generate a random IV.
    self.iv = Sequel.blob(aes.random_iv)

    # Generate a random salt.
    self.salt = Sequel.blob(OpenSSL::Random.random_bytes(16))

    # Get the key from the password and salt.
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt, 20_000, 16)

    # Encrypt the data
    self.data_crypt = Sequel.blob(aes.update(self.username) + aes.final)
  end

  def check_password(password, confirm_pass)
    if password.empty?
      errors.add("password", "Please fill in your password")
    else
      errors.add("password", "Password must be at least 8 characters") if password.length < 8
    end

    errors.add("confirm_password", "Please confirm your password") if confirm_pass.nil? || confirm_pass.empty?
    errors.add("password_mismatch", "Passwords do not match, please try again") if password != confirm_pass
  end

  def self.find_user(field)
    if field.include? "sheffield.ac.uk"
      User.first(university_email: field)
    else
      User.first(username: field)
    end
  end
end

