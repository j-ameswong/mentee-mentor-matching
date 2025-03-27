require_relative '../db/db'
Dir["#{__dir__}/*.rb"].each do |file|
  require file
end

# TODO: create_user command, rescue ValidationError by doing nothing instead of reloading view
class User < Sequel::Model(DB)
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

    errors.add(:role, "must be valid") unless ROLES.include?(role)
    if email.nil? || email.empty?
      errors.add(:email, "must be filled in")
    else
      errors.add(:email, "already taken") unless User.first(email: email).nil?
      errors.add(:email, "is in invalid format") unless valid_email_address?(email)
      errors.add(:email, "must be your university email") unless valid_email?(email)
    end

    errors.add(:username, "cannot be empty") if username.empty?
    errors.add(:username, "must be valid") unless valid_input?(username)
    errors.add(:username, "already exists") unless User.first(username: username).nil?

    errors.add(:terms, "must be accepted") if @terms.nil? || @terms.empty?
  end

  def admin?
    self.role == "admin"
  end

  def mentor?
    self.role == "mentor"
  end

  def mentee?
    self.role == "mentee"
  end

  def self.find_user(field)
    # either lookup users table by email or username
    valid_email_address?(field) ? user = self.first(email: field) : user = self.first(username: field)

    # basically, if no user found create a user instance, appears in controllers/login.rb
    if user.nil?
      user = User.new
      user.errors.add(:field, "User not found")
      user.errors.add(:field, "Can't be blank") if field.empty?
      return user
    end

    user
  end

  def gen_uid
    # generate until return unique 9 digit id
    id = 100000000 + rand(899999999)
    while User.first(id: id) != nil
      id = 100000000 + rand(899999999)
    end
    id
  end

  def delete_from_all
    UserLanguage.where(user_id: self.id).delete
    UserExpertise.where(user_id: self.id).delete

    Match.where(mentor_id: self.id).delete # if Match.first(mentor_id: self.id)
    Match.where(mentee_id: self.id).delete # if Match.first(mentee_id: self.id)

    mentee_profile = MenteeProfile.first(user_id: self.id)
    mentee_profile.delete if mentee_profile

    mentor_profile = MentorProfile.first(user_id: self.id)
    mentor_profile.delete if mentor_profile

    profile = Profile.first(user_id: self.id)
    profile.delete if profile

    authentication = Authentication.first(user_id: self.id)
    authentication.delete if authentication

    self.delete
  end

  # Signup method, admins bypass most of it, only needing to be in users and auth table initially
  def signup(params)
    # users table
    self.id = self.gen_uid
    params = params.merge(:user_id => self.id)
    self.username = params.fetch(:username, "").strip.downcase
    self.email = params.fetch(:email, "").strip.downcase
    self.role = params[:role]

    # profiles table, Profile class, admins dont need profile
    unless self.admin?
      profile = Profile.new
      profile.update!(params)
      unless profile.valid?
        puts "Error when writing to profiles!"
        self.errors.merge!(profile.errors)
        #puts self.errors.full_messages
      end

      # mentor_profiles table, MentorProfile class
      if self.mentor?
        mentor = MentorProfile.new
        mentor.update!(params)
        unless mentor.valid?
          puts "Error when writing to mentor_profiles!"
          self.errors.merge!(mentor.errors)
          #puts self.errors.full_messages
        end
      end

      if self.mentee?
        mentee = MenteeProfile.new
        mentee.update!(params)
      end
    end

    auth = Authentication.new
    auth.update!(params)
    unless auth.valid?
      puts "Error when writing to authentication!"
      self.errors.merge!(auth.errors)
    end

    @terms = params.fetch(:terms, "").strip

    # Looks like the memory is referencing the actual hash, and it's rewritten when checking with .valid?
    # Below is to save the values up to a certain point and then re-appending them
    all_other_errors = self.errors.clone
    if self.valid? && (self.errors.nil? || self.errors.empty?)
      puts "Attempting to save new user with UID: #{self.id}"
      begin
        self.save
        profile.save if profile
        mentor.save if mentor
        mentee.save if mentee
        auth.save if auth
        true
      rescue
        self.delete_from_all
        puts "Critical error when handling signup!"
        puts $!.backtrace.join("\n") unless $!.nil?
        false
      end
    else
      puts "Errors found!"
      puts self.errors.merge!(all_other_errors).full_messages
      false
    end
  end
end

