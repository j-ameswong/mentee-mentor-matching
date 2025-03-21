require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'
require_relative '../models'

class Match < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :mentor_id, class: :User
  many_to_one :mentee_id, class: :User

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

  def end
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
