require_relative "../db/db"

class Authentication < Sequel::Model(:authentication)
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def update!(params)
    @params = params
    self.user_id = params.fetch(:user_id) if params.key?(:user_id)
    params.key?(:role) ? @role = params[:role] : @role = self.user.role

    # Admin does not have a password on sign up
    # ok, so basically, later at signup/admin, need to make sure params[:role] is admin,
    # then when approving by admin, do not have params role
    unless params[:role] == "admin"
      @password = params.fetch(:password, "").strip
      @confirm_password = params.fetch(:confirm_password, "").strip

      if params.key?(:password) && params.key?(:confirm_password)
        aes = OpenSSL::Cipher.new("AES-128-CBC").encrypt
        self.iv = Sequel.blob(aes.random_iv)
        self.salt = Sequel.blob(OpenSSL::Random.random_bytes(16))
        aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@password, self.salt, 20_000, 16)
        self.data_crypt = Sequel.blob(aes.update(self.user_id.to_s) + aes.final)
      end
    end

    # Below is universally applied
    self.approved = false if self.approved.nil? # be default false, after admin approval, true
    self.first_time_login = true unless self.first_time_login
  end

  def login(params)
    @params = params
    @password = params.fetch(:password, "").strip
    if self.data_crypt.nil?
      self.user.errors.add(:password, "not been set by admin, please contact admin")
    else
      aes = OpenSSL::Cipher.new('AES-128-CBC').decrypt
      aes.iv = self.iv
      aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@password, self.salt, 20_000, 16)
      begin
        aes.update(self.data_crypt) + aes.final
      rescue OpenSSL::Cipher::CipherError
        self.user.errors.add(:password, "was incorrect")
      end
    end

    self.user.errors.add(:approval, "Approval has not been granted by admin yet, please try again later") unless self.approved
    return false if self.user.errors.any?
    true
  end

  def validate
    super

    errors.add(:user_id, "cannot be empty") if user_id.nil?
    errors.add(:approved, "status not found") if approved.nil?
    errors.add(:first_time_login, "status not found") if first_time_login.nil?

    # @role will be nil outside of signup
    unless @role == "admin"
      errors.add(:iv, "cannot be empty") if iv.nil?
      errors.add(:salt, "cannot be empty") if salt.nil?
      errors.add(:data_crypt, "cannot be empty") if data_crypt.nil?

      if @params && @params.key?(:password)
        if @password.nil? || @password.empty?
          errors.add(:password, "cannot be blank")
        else
          errors.add(:password, "must be more than 8 characters") if @password.length < 9
        end
      end

      if @params && @params.key?(:confirm_password)
        if @confirm_password.nil? || @confirm_password.empty?
          errors.add(:confirm_password, "cannot be blank")
        else
          errors.add(:confirm_password, "must match password") unless @password == @confirm_password
        end
      end
    end
  end
end
