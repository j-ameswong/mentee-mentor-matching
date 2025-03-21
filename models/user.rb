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
    self.role == 'admin'
  end

  def mentor?
    self.role == 'mentor'
  end

  def mentee?
    self.role == 'mentee'
  end
end

