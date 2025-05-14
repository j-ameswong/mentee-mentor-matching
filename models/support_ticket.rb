require_relative '../db/db'

class SupportTicket < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :sent_by, class: :User
  many_to_one :target_id, class: :User
  many_to_one :type, class: :TicketType

  def self.create!(params)
    ticket = SupportTicket.new
    case params[:type]
    when report?
      report!(params)
    when withdraw?
      withdraw!(params)
    else
      puts "Invalid ticket type"
    end
    # TODO: etc...
  end

  def report?
    TicketType.first(name: "report").id
  end

  def withdraw?
    TicketType.first(name: "withdraw").id
  end

  def report!(params)
    return if params[:type].nil? ||
      params[:type] != TicketType.first(name: "report").id

    SupportTicket.create(
      :sent_by => params[:sent_by],
      :target_id => params[:target_id],
      :is_read => false,
      :ticket.type => params[:type],
      :ticket.details => params[:details]
    )
  end

  def withdraw!(params)
  end
end

