require_relative '../db/db'
class UserLanguage < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user
  many_to_one :language, key: :id
end