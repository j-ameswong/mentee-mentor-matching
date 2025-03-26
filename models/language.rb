require_relative "../db/db"

class Language < Sequel::Model
  plugin :timestamps, update_on_create: true

  one_to_one :user_language
end