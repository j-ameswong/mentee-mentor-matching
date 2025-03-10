require 'sequel'
require 'digest'
require 'date'
require_relative '../db/db'

# Specify user table, by default it downcases User and adds an s to the end
class User < Sequel::Model(DB)
  def signup(params)
    username = params.fetch("university_email", "").strip
    errors.add("username", "cannot be empty") if username.empty?

    errors.add("username", "already taken") unless User.first(university_email: username).nil?

    password = params.fetch("password", "").strip
    errors.add("password", "cannot be empty") if password.empty?

    terms = params.fetch("terms", "").strip
    errors.add("terms", "must be accepted") if terms.empty?

    puts errors if !errors.empty?
    return false unless errors.empty?
    #return false if !validate

    self.university_email = username

    self.date_of_birth = params.fetch("date_of_birth", "").strip

    self.first_name = params.fetch("first_name", "").strip

    self.last_name = params.fetch("last_name", "").strip

    self.acc_type = params.fetch("acc_type", "").strip

    self.id = gen_uid(username)

    password = params.fetch("password", "").strip

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

    true
  end

  def login(params)
    password = params.fetch("password", "").strip

    # Set up AES for decryption.
    aes = OpenSSL::Cipher.new('AES-128-CBC').decrypt

    # Set the IV.
    aes.iv = iv

    # Get the key from the password and salt.
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt, 20_000, 16)

    # Try to decrypt the data.
    begin
      aes.update(data_crypt) + aes.final
    rescue OpenSSL::Cipher::CipherError
      nil
    end
  end

  def gen_uid(username)
    all_usernames = User.select(:university_email).map(:university_email)

    idd = 100000000 + rand(899999999)
    while all_usernames.include? idd
      idd = 100000000 + rand(899999999)
    end

    return idd
  end

  def age(date_of_birth)
    dob = DateTime.parse(date_of_birth)
    now = DateTime.now
    age = TimeDifference.between(dob, now).in_years.to_i
    
    return age
  end
  
  def img_hash(username)
    hash = Digest::SHA256.hexdigest(username)
    return hash
  end

  def validate 
    super
    errors.add("university_email", "fill in your email address") if !university_email || university_email.empty?
    errors.add("first_name", "fill in your first name") if !first_name || first_name.empty?
    errors.add("last_name", "fill in your last name") if !last_name || last_name.empty?
    errors.add("date_of_birth", "cannot be empty") if !date_of_birth || date_of_birth.empty?
  end

  def check_password(pass, confirm_pass)
    errors.add("password", "fill in your password") if !password || password.empty? 
    errors.add("confirm_password", "confirm your password") if !password-confirm || password-confirm.empty? 
    errors.add("password_mismatch", "passwords do not match, please try again") if !@user.check_password(password, confirm_pass)
  end 

  

=begin
  def self.gen_pass_hash(id, pass = 12345678)
    user = DB[:users].where(id: id)
    last_name = user[:last_name]
    date_of_birth = user[:date_of_birth]

    password = (Digest::SHA256.hexdigest ('salt' + pass))
    return password
  end
=end
end
