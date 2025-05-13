require_relative "../db/db"

class Message < Sequel::Model
  one_to_many :user_message, key: :message_id

end

  