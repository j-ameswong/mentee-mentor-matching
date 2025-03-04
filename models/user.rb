require 'sequel'
require 'digest'
require_relative '../db/db'

# Specify user table, by default it downcases User and adds an s to the end
class User < Sequel::Model(DB)
  def signup(params)
    username = params.fetch("university_email", "").strip
    #errors.add("username", "cannot be empty") 

    errors.add("username", "already taken") unless User.first(university_email: username).nil?

    password = params.fetch("password", "").strip
    errors.add("password", "cannot be empty") if password.empty?

    puts errors if !errors.empty?
    return false unless errors.empty?

    self.university_email = username

    self.date_of_birth = params.fetch("date_of_birth", "").strip

    self.first_name = params.fetch("first_name", "").strip

    self.last_name = params.fetch("last_name", "").strip

    self.acc_type = params.fetch("acc_type", "").strip

    self.id = gen_uid(username)

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