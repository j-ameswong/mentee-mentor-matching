require_relative '../db/db'

class TicketTypes < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :sent_by, class: :User
  many_to_one :target_id, class: :User
  many_to_one :type, class: :TicketType
end

