require_relative '../db/db'

class SupportTicket < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :sent_by_user, class: :User
  many_to_one :target_id_user, class: :User
  many_to_one :ticket_type, class: :TicketType

  def self.create!(params)
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
      params[:type].to_i != TicketType.first(name: "report").id

    ticket = SupportTicket.new

    ticket.sent_by = params[:sent_by]
    ticket.target_id = params[:target_id]
    ticket.is_read = false
    ticket.type = params[:type]
    ticket.details = params[:details]

    ticket.save
    ticket.inspect
  end

  def self.withdraw!(params)
  end
end

