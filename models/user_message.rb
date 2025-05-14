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

  def received_by
    receiver = User.first(id: self[:received_by])
    receiver ? receiver.username : "Unknown"
  end
  
  # uility method to send a message to a user
  def self.send_message(options = {})
    options = {
      sent_by: "System",
      message_type: nil,
      received_by: nil  
    }.merge(options)

    return false if options[:message_type].nil? || options[:received_by].nil?

    message = Message.first(message_type: options[:message_type])
    return false unless message
    
    create(
      message_id: message.id,
      sent_by: options[:sent_by],
      received_by: options[:received_by],
      read_status: 0  # Initialize as unread
    )
  end
end