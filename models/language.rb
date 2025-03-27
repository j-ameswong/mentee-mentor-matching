require_relative "../db/db"

class Language < Sequel::Model
  one_to_one :user_language
end