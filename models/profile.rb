require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'

class Profile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
  end
end

class MentorProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user
  one_to_many :expertises, class: :UserExpertise, key: :user_id

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
    errors.add(:user_id, 'must belong to a mentor') unless user&.mentor?
  end

  def available
    num_matches < max_matches
  end

  def experience
    # return current date - date of first match created, fetch from matches table
  end
end

class MenteeProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
    errors.add(:user_id, 'must belong to a mentee') unless user&.mentee?
  end

  def available?
    availability == "true" ? true : false
  end
end
