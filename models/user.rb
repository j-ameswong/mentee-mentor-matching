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

  one_to_many :user_languages
  one_to_many :user_expertises

  ROLES = %w[admin mentor mentee] # fancy way to do a comma separated list

  def validate
    super
    errors.add(:email, 'cannot be empty') if email.nil? || email.empty?
    errors.add(:role, 'must be valid') unless ROLES.include?(role)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    self.role == 'admin'
  end

  def mentor?
    self.role == 'mentor'
  end

  def mentee?
    self.role == 'mentee'
  end

  def find_user(field)
    # either lookup users table by email or username
    Validation.str_email_address(field) ? user = self.first(email: field) : user = self.first(username: field)

    # basically, if no user found create a user instance
    self.errors.add(:field, "Can't be blank") if user.nil?
    user.nil? ? self.new : user
  end
end

