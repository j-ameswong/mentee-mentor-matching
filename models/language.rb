require_relative "../db/db"

class Language < Sequel::Model
  one_to_many :user_language, key: :language_id
end