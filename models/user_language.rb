require_relative '../db/db'
class UserLanguage < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user
  one_to_one :language
end