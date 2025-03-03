require 'sequel'
require_relative '../db/db'

# Specify user table, by default it downcases User and adds an s to the end
class User < Sequel::Model
  def check_id_exists(id)
    return false if User.first(id: id).nil?
    true
  end

  def signup(params)
    username = params.fetch("username", "").strip
    errors.add("username", "cannot be empty") if username.empty?

    errors.add("username", "already taken") unless User.first(university_email: username).nil?

    data = params.fetch("data", "").strip
    errors.add("data", "cannot be empty") if data.empty?

    password = params.fetch("password", "").strip
    errors.add("password", "cannot be empty") if password.empty?

    return false unless errors.empty?

    self.username = username

    # Set up AES for encryption.
    aes = OpenSSL::Cipher.new('AES-128-CBC').encrypt

    # Generate a random IV.
    self.iv = Sequel.blob(aes.random_iv)

    # Generate a random salt.
    self.salt = Sequel.blob(OpenSSL::Random.random_bytes(16))

    # Get the key from the password and salt.
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt, 20_000, 16)

    # Encrypt the data
    self.data_crypt = Sequel.blob(aes.update(data) + aes.final)

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
    self.idd = '000000000'
    self.unique = false
    all_usernames = DB[:university_email].all

    self.attempts = 0
    while not unique
      (0..8).each do |x|
        idd[x] = (username[x].ord + attempts).to_s[-1] 
      end

      all_ids.each do |each_id|
        unique = false if each_id == idd
      end
    end
    
    if idd[0] == 0
      idd[0] = 1
    end
    #if idd.length < 9
    #  idd = idd + '0'* (9 - idd.length) 
    #end
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