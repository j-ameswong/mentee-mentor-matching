require_relative '../db/db'

class UserMessage < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user, key: :received_by
  many_to_one :sender, class: :User, key: :sent_by
  many_to_one :message
  
  def read?
    self[:read_status] == 1
  end
  
  def mark_as_read!
    self.update(read_status: 1)
  end
  
  def mark_as_unread!
    self.update(read_status: 0)
  end
  
  def sent_by
    sender = User.first(id: self[:sent_by])
    sender ? sender.username : "System"
  end
  
  def self.send_message(sent_by_id, received_by_id, message_type)
    message = Message.first(message_type: message_type)
    return false unless message
    
    create(
      message_id: message.id,
      sent_by: sent_by_id,
      received_by: received_by_id,
      read_status: 0
    )
  end
end