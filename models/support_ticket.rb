require_relative '../db/db'

class SupportTicket < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :sent_by_user, key: :sent_by, class: :User
  many_to_one :target_id_user, key: :target_id, class: :User
  many_to_one :ticket_type, key: :type, class: :TicketType

  def self.create!(params)
    puts params
    case params[:type].to_i
    when report?
      SupportTicket.report!(params)
    when withdraw?
      SupportTicket.withdraw!(params)
    else
      puts "Invalid ticket type"
    end
    # TODO: etc...
  end

  def self.report?
    TicketType.first(name: "report").id
  end

  def self.withdraw?
    TicketType.first(name: "withdrawal").id
  end

  def self.report!(params)
    return if params[:type].nil? ||
      params[:type].to_i != self.report?

    ticket = SupportTicket.new

    ticket.sent_by = params[:sent_by]
    ticket.target_id = params[:target_id]
    ticket.is_read = false
    ticket.type = params[:type]
    ticket.details = params[:details]

    ticket.save
    #ticket.inspect
  end

  def self.withdraw!(params)
    return if params[:type].nil? ||
      params[:type].to_i != self.withdraw?

    ticket = SupportTicket.new

    ticket.sent_by = params[:sent_by]
    ticket.target_id = params[:target_id]
    ticket.is_read = false
    ticket.type = params[:type]
    ticket.details = params[:details]

    ticket.save
    ticket.inspect
  end

  def self.withdrawing?(match)
    SupportTicket.first(sent_by: match.mentee_id, target_id: match.mentor_id, type: self.withdraw?) ||
      SupportTicket.first(sent_by: match.mentor_id, target_id: match.mentee_id, type: self.withdraw?)
  end
end

