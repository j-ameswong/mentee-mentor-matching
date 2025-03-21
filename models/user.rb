require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'

class User < Sequel::Model
  plugin :timestamps, update_on_create: true

  one_to_one :authentication
  one_to_one :profile
  one_to_one :mentor_profile
  one_to_one :mentee_profile

  one_to_many :mentor_matches, class: :Match, key: :mentor_id
  one_to_many :mentee_matches, class: :Match, key: :mentee_id

  ROLES = %w[admin mentor mentee]

  def validate
    super
    # errors.add(:email, 'cannot be empty') if email.nil? || email.empty?
    # errors.add(:role, 'must be valid') unless ROLES.include?(role)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    role == 'admin'
  end

  def mentor?
    role == 'mentor'
  end

  def mentee?
    role == 'mentee'
  end
end

# models/authentication.rb
class Authentication < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
    errors.add(:salt, 'cannot be empty') if salt.nil? || salt.empty?
    errors.add(:iv, 'cannot be empty') if iv.nil? || iv.empty?
    errors.add(:data_crypt, 'cannot be empty') if data_crypt.nil? || data_crypt.empty?
  end
end

# models/profile.rb
class Profile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
  end

  # Serialize and deserialize JSON fields
  def skills
    JSON.parse(super) rescue []
  end

  def skills=(value)
    super(value.is_a?(String) ? value : value.to_json)
  end

  def interests
    JSON.parse(super) rescue []
  end

  def interests=(value)
    super(value.is_a?(String) ? value : value.to_json)
  end
end

# models/mentor_profile.rb
class MentorProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
    errors.add(:user_id, 'must belong to a mentor') unless user && user.mentor?
  end

  def availability
    JSON.parse(super) rescue {}
  end

  def availability=(value)
    super(value.is_a?(String) ? value : value.to_json)
  end
end

# models/mentee_profile.rb
class MenteeProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
    errors.add(:user_id, 'must belong to a mentee') unless user && user.mentee?
  end

  def availability
    JSON.parse(super) rescue {}
  end

  def availability=(value)
    super(value.is_a?(String) ? value : value.to_json)
  end

  def goals
    JSON.parse(super) rescue []
  end

  def goals=(value)
    super(value.is_a?(String) ? value : value.to_json)
  end
end

# models/match.rb
class Match < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :mentor, class: :User
  many_to_one :mentee, class: :User
  many_to_one :admin, class: :User

  STATUSES = %w[pending active completed cancelled]

  def validate
    super
    # errors.add(:mentor_id, 'cannot be empty') if mentor_id.nil?
    # errors.add(:mentee_id, 'cannot be empty') if mentee_id.nil?
    # errors.add(:status, 'must be valid') unless STATUSES.include?(status)
    # errors.add(:mentor_id, 'must belong to a mentor') unless mentor && mentor.mentor?
    # errors.add(:mentee_id, 'must belong to a mentee') unless mentee && mentee.mentee?
  end

  def active?
    status == 'active'
  end

  def pending?
    status == 'pending'
  end

  def completed?
    status == 'completed'
  end

  def cancelled?
    status == 'cancelled'
  end

  def activate
    self.status = 'active'
    self.start_date = Date.today
    save
  end

  def complete
    self.status = 'completed'
    self.end_date = Date.today
    save
  end

  def cancel
    self.status = 'cancelled'
    self.end_date = Date.today
    save
  end
end
