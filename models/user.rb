require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'

# Specify user table, by default it downcases User and adds an s to the end
class User < Sequel::Model(DB)
  def signup(params)
    self.university_email = params.fetch("university_email", "").strip
    self.date_of_birth = params.fetch("date_of_birth", "").strip
    self.first_name = params.fetch("first_name", "").strip
    self.last_name = params.fetch("last_name", "").strip
    self.acc_type = params.fetch("acc_type", "").strip
    self.id = gen_uid
    self.approved = "false"
    self.first_time_login = "true"
    terms = params.fetch("terms", "").strip
    password = params.fetch("password", "").strip
    confirm_password = params.fetch("confirm_password", "").strip

    errors.add("terms", "must be accepted") if terms.nil? || terms.empty?
    errors.add("email", "Fill in your email address") if university_email.nil? || university_email.empty?
    errors.add("email", "Already taken") unless User.first(university_email: university_email).nil?
    errors.add("first_name", "Fill in your first name") if first_name.nil? || first_name.empty?
    errors.add("last_name", "Fill in your last name") if last_name.nil? || last_name.empty?
    errors.add("date_of_birth", "Cannot be empty") if date_of_birth.nil? || date_of_birth.empty?
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
    self.data_crypt = Sequel.blob(aes.update(university_email) + aes.final)

    if iv.nil? || iv.empty? || salt.nil? || salt.empty? || data_crypt.nil? || data_crypt.empty?
      errors.add("encryption", "Encryption error")
    end

    # If is admin, only field required is email, therefore bypass all errors
    if params.fetch("admin_creation", "") == "true"
      errors = {}
    end

    puts errors unless errors.nil? || errors.empty?
    return false unless errors.nil? || errors.empty?

    true
  end

  def login(params)
    password = params.fetch("password", "").strip

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

    errors.add("approval", "Approval not granted by admin") if self.approved != "true"
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
    self.data_crypt = Sequel.blob(aes.update(self.university_email) + aes.final)
  end

  def check_password(password, confirm_pass)
    errors.add("password", "Please fill in your password") if password.nil? || password.empty?
    errors.add("confirm_password", "Please confirm your password") if confirm_pass.nil? || confirm_pass.empty?
    errors.add("password_mismatch", "Passwords do not match, please try again") if password != confirm_pass
  end
end

