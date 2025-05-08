require "sequel"
require "digest"
require "date"
require "time_difference"
require_relative "../db/db"

class Match < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_many :mentor_id, class: :users
  many_to_many :mentee_id, class: :users

  STATUSES = %w[pending active completed cancelled]

  def validate
    super
    # errors.add(:mentor_id, "cannot be empty") if mentor_id.nil?
    # errors.add(:mentee_id, "cannot be empty") if mentee_id.nil?
    # errors.add(:status, "must be valid") unless STATUSES.include?(status)
    # errors.add(:mentor_id, "must belong to a mentor") unless mentor && mentor.mentor?
    # errors.add(:mentee_id, "must belong to a mentee") unless mentee && mentee.mentee?
  end

  def active?
    status == "active"
  end

  def pending?
    status == "pending"
  end

  def completed?
    status == "completed"
  end

  def cancelled?
    status == "cancelled"
  end

  def self.exists?(mentee_id, mentor_id)
    true if Match.first(mentee_id: mentee_id, mentor_id: mentor_id)
  end

  def self.generate!(params)
    match = Match.new

    match.status = "pending"
    match.mentor_id = params[:mentor_id]
    match.mentee_id = params[:mentee_id]
    match.application_message = params[:message]

    puts match.inspect
    match.save
  end

  def activate
    self.status = "active"
    self.start_date = Date.today
    save
  end

  def end
    self.status = "completed"
    self.end_date = Date.today
    save
  end

  def cancel
    self.status = "cancelled"
    self.end_date = Date.today
    save
  end
end
