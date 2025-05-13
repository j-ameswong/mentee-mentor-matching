require_relative '../db/db'

class TicketType < Sequel::Model
  plugin :timestamps, update_on_create: true

  one_to_many :support_ticket, key: :type
end

