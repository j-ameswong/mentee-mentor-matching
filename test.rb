require_relative './models/user'

printf "> "
choice = gets.chomp

if choice == "1"
  @user = User.new

  params = {:username => "contessa", :email => "contessa@sheffield.ac.uk", :password => "contessa1", :confirm_password => "contessa1",
            :role => "mentor", :terms => "terms_accepted", :year_of_study => "2", :date_of_birth => (Date.today - 365*20).to_s, :first_name => "Arch", :last_name => "Linux"}

  @user.signup(params)
elsif choice == "2"
  printf "> ID: "
  id = gets.chomp.to_i

  User.delete_from_all(id)
elsif choice == "3"
  aes = OpenSSL::Cipher.new("AES-128-CBC").encrypt
  iv = Sequel.blob(aes.random_iv)
  salt = Sequel.blob(OpenSSL::Random.random_bytes(16))
  aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1("admin", salt, 20_000, 16)
  data_crypt = Sequel.blob(aes.update(self.user_id.to_s) + aes.final)
end

User.where(id: 454920228).each do |user|
  user.delete_from_all
end

Profile.where(last_name: "Freeborn").each do |heretic|
  heretic.delete
end