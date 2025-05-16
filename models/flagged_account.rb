require_relative '../db/db'

class FlaggedAccount < Sequel::Model
  plugin :timestamps, update_on_create: true
end

