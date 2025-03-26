require_relative "../db/db"

class Nationality < Sequel::Model
  plugin :timestamps, update_on_create: true

  one_to_one :profile
end