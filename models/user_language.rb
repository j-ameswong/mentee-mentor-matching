require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'
class UserLanguage < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user
end