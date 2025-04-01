require_relative "../db/db"

class Nationality < Sequel::Model
  one_to_many :profile, key: :nationality_id
end