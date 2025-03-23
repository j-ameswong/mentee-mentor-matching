require "sequel"
require "digest"
require "date"
require "time_difference"
require_relative "../db/db"

class Profile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def update!(params)
    @role = params[:role] if params.key?(:role)
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
    errors.add(:user_id, "cannot be empty") if user_id.nil?
  end
end

class MentorProfile < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def update!(params)
    params.key?(:role) ? @role = params[:role] : @role = "mentor"
    self.user_id = params[:user_id] if params.key?(:user_id)
    self.year_of_study = params[:year_of_study] if params.key?(:year_of_study)
    self.num_matches = 0 if self.num_matches.nil?
    self.num_matches = params[:num_matches] if params.key?(:num_matches)
    self.max_matches = 0 if self.max_matches.nil?
    self.max_matches = params[:max_matches] if params.key?(:max_matches)
  end

  def validate
    super
    errors.add(:user_id, "cannot be empty") if user_id.nil?
    errors.add(:year_of_study, "first years cannot be mentors") if year_of_study < 2
    errors.add(:num_matches, "cannot exceed max_matches set") if num_matches > max_matches
    errors.add(:max_matches, "cannot exceed maximum allowed") if max_matches > 3
    errors.add(:user_id, "must belong to a mentor") unless @role == mentor?
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

  def update!(params)
    params.key?(:role) ? @role = params[:role] : @role = "mentee"
    self.user_id = params[:user_id] if params.key?(:user_id)
    self.year_of_study = params[:year_of_study] if params.key?(:year_of_study)
    self.num_matches = 0 if self.num_matches.nil?
    self.num_matches = params[:num_matches] if params.key?(:num_matches)
    self.max_matches = 0 if self.max_matches.nil?
    self.max_matches = params[:max_matches] if params.key?(:max_matches)
  end

  def validate
    super
    errors.add(:user_id, "cannot be empty") if user_id.nil?
    errors.add(:user_id, "must belong to a mentee") unless user&.mentee?
  end

  def available?
    availability == "true" ? true : false
  end
end
