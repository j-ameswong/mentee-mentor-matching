require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'

class Profile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def change(params)
    self.user_id = params[:id] if params.key?(:id)
    self.date_of_birth = params[:date_of_birth] if params.key?(:date_of_birth)
    self.first_name = params.fetch(:first_name, "").strip.capitalize if params.key?(:first_name)
    self.last_name = params.fetch(:last_name, "").strip.capitalize if params.key?(:last_name)
    self.nationality = params[:nationality] if params.key?(:nationality)
    self.gender = params[:gender] if params.key?(:gender)
    self.profile_picture = params[:profile_picture] if params.key?(:profile_picture)
    self.bio_brief = params[:bio_brief] if params.key?(:bio_brief)
    self.bio_detailed = params[:bio_detailed] if params.key?(:bio_detailed)
  end

  def return_hash(value)
    Digest::SHA256.hexdigest(value)
  end

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
  end
end

class MentorProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

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
