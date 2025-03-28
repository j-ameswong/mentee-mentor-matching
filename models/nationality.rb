require_relative "../db/db"

class Nationality < Sequel::Model
  one_to_one :profile, key: :nationality_id
end