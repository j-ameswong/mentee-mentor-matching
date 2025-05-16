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
    mentor = User.first(id: self.mentor_id)
    errors.add(:mentor_id, "must belong to a mentor") unless mentor && mentor.mentor?
    mentee = User.first(id: self.mentee_id)
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

  def self.exists?(id_1, id_2)
    user1 = User.first(id: id_1)
    user2 = User.first(id: id_2)

    # Return false if either user doesn't exist
    return false unless user1 && user2

    # Determine roles
    if user1.mentee? && user2.mentor?
      mentee_id, mentor_id = id_1, id_2
    elsif user1.mentor? && user2.mentee?
      mentor_id, mentee_id = id_1, id_2
    else
      return false # Either same roles or invalid roles
    end

    Match.first(mentee_id: mentee_id, mentor_id: mentor_id).present?
  end

  def self.generate!(params)
    match = Match.new

    match.status = "pending"
    match.mentor_id = params[:mentor_id].to_i
    match.mentee_id = params[:mentee_id].to_i
    match.application_message = params[:message]
    return false if params[:message].split(" ").length > 100

    #puts match.inspect
    match.save
    true
  end

  def activate
    self.status = "active"
    self.start_date = Date.today
    self.end_date = Time.at(GlobalVariable.END_DATE).to_datetime
    puts "Match activated for mentor #{self.mentor_id} and mentee #{self.mentee_id}"
    self.mentee.mentee_profile.update(availability: false)
    self.mentee.mentee_profile.save
    self.mentor.mentor_profile.update(num_matches: self.mentor.mentor_profile.num_matches + 1) # this value doesnt matter
    self.mentor.mentor_profile.save
    save
    self.mentee.mentee_profile.update({})
    self.mentee.mentee_profile.save
    self.mentor.mentor_profile.update({})
    self.mentor.mentor_profile.save
  end

  def decline
    self.status = "declined"
    puts "Match declined for mentor #{self.mentor_id} and mentee #{self.mentee_id}"
    save
  end

  def end
    self.status = "completed"
    save
    self.mentee.mentee_profile.update(availability: true)
    self.mentee.mentee_profile.save
    self.mentor.mentor_profile.update(availability: true)
    self.mentor.mentor_profile.save

    UserMessage.send_message(
           sent_by: "System",
           received_by: self.mentee_id,
           message_type: 'match_completed'
         )

    UserMessage.send_message(
           sent_by: "System",
           received_by: self.mentor_id,
           message_type: 'match_completed'
         )
    true
  end

  def check_end
    #puts "Checking end date..."
    # puts "end date--: #{self.end_date}"
    # puts User.where(id: self.mentor_id).first.username
    #puts Date.today.to_datetime
    if self.end_date.nil?
      self.end_date = Time.at(GlobalVariable.END_DATE).to_datetime
    else
      if Date.today.to_datetime.to_i > self.end_date.to_datetime.to_i
        #puts "THE END TIMES HAVE ARRIVED"
        return self.end
      end
    end
    false
  end

  def cancel(perma = false)
    already_cancelled = false
    already_cancelled = true if self.status == "cancelled"

    unless already_cancelled
      self.end_date = Date.today
      self.status = "cancelled"
      save
      unless self[:mentee_profile].nil?
        self.mentee.mentee_profile.update(availability: true)
        self.mentee.mentee_profile.save
        self.mentor.mentor_profile.update(availability: true)
        self.mentor.mentor_profile.save
      end

      begin
        UserMessage.send_message(
          sent_by: "System",
          received_by: self.mentee_id,
          message_type: "match_cancelled"
        )
        UserMessage.send_message(
          sent_by: "System",
          received_by: self.mentor_id,
          message_type: "match_cancelled"
        )
        puts "Match cancelled successfully"
      rescue => e
        puts "Error sending match cancelled notification: #{e.message}"
      end
    end

    if perma
      begin
        UserMessage.send_message(
          sent_by: "System",
          received_by: self.mentee_id,
          message_type: "account_deleted"
        )
        UserMessage.send_message(
          sent_by: "System",
          received_by: self.mentor_id,
          message_type: "account_deleted"
        )
        self.delete
        puts "Account deleted successfully"
      rescue => e
        puts "Error sending match cancelled notification: #{e.message}"
      end
    end
  end
end
