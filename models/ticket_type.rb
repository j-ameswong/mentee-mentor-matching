require_relative '../db/db'

class TicketType < Sequel::Model
  one_to_many :support_ticket, key: :type

  def self.id
    id
  end
end