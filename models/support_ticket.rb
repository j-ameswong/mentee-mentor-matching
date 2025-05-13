require_relative '../db/db'

class SupportTicket < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :sent_by, class: :User
  many_to_one :target_id, class: :User
  many_to_one :type, class: :TicketType

  def self.create!(params)
    ticket = SupportTicket.new
    case params[:type]
    when 'withdrawal'
    end
    # TODO: etc...
  end
end

