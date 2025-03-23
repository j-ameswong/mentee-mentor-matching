require_relative "../db/db"

class Authentication < Sequel::Model(:authentication)
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def update!(params)
    self.user_id = params.fetch(:user_id) if params.key?(:user_id)
    params.key?(:role) ? @role = params[:role] : @role = self.user.role

    # Admin does not have a password on sign up
    unless @role == "admin"
      @password = params.fetch(:password, "").strip
      @confirm_password = params.fetch(:confirm_password, "").strip

      if params.key?(:password) && params.key?(:confirm_password)
        aes = OpenSSL::Cipher.new("AES-128-CBC").encrypt
        self.iv = Sequel.blob(aes.random_iv)
        self.salt = Sequel.blob(OpenSSL::Random.random_bytes(16))
        aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@password, self.salt, 20_000, 16)
        self.data_crypt = Sequel.blob(aes.update(self.user_id) + aes.final)
      end
    end

    # Below is universally applied
    self.approved = false # be default false, after admin approval, true
    self.first_time_login = true
  end
  def validate
    super
    errors.add(:user_id, "cannot be empty") if user_id.nil?
    errors.add(:approved, "status not found") if approved.nil?
    errors.add(:first_time_login, "status not found") if first_time_login.nil?

    unless self.user.admin?
      errors.add(:iv, "cannot be empty") if iv.nil?
      errors.add(:salt, "cannot be empty") if salt.nil?
      errors.add(:data_crypt, "cannot be empty") if data_crypt.nil?
      errors.add(:password, "cannot be blank") if @password.nil? || @password.empty?
      errors.add(:password, "must be more than 8 characters") if @password.length < 9
      errors.add(:confirm_password, "cannot be blank") if
      errors.add(:confirm_password, "must match password") unless Validation.match(@password, @confirm_password)
    end
  end
end
