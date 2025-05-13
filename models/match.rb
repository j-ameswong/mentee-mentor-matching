require "sequel"
require "digest"
require "date"
require "time_difference"
require_relative "../db/db"

class Match < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :mentor, class: :User
  many_to_one :mentee, class: :User

  STATUSES = %w[pending active completed cancelled declined]

  def validate
    super
    errors.add(:mentor_id, "cannot be empty") if mentor_id.nil?
    errors.add(:mentee_id, "cannot be empty") if mentee_id.nil?
    errors.add(:status, "must be valid") unless STATUSES.include?(status)
    errors.add(:mentor_id, "must belong to a mentor") unless mentor && mentor.mentor?
    errors.add(:mentee_id, "must belong to a mentee") unless mentee && mentee.mentee?
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

  def declined?
    status == "declined"
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

    #puts match.inspect
    match.save
    match.mentor.mentor_profile.update(num_matches: match.mentor.mentor_profile.num_matches + 1)
  end

  def activate
    self.status = "active"
    self.start_date = Date.today
    self.mentee.mentee_profile.update(:availability => false)
    puts "Match activated for mentor #{self.mentor_id} and mentee #{self.mentee_id}"
    save
  end

  def decline
    self.status = "declined"
    puts "Match declined for mentor #{self.mentor_id} and mentee #{self.mentee_id}"
    save
  end

  def end
    self.status = "completed"
    # TODO: set end_date to global variable semester end date
    self.end_date = Date.today
    save
  end

  def cancel
    self.status = "cancelled"
    self.end_date = Date.today
    save
  end
end
