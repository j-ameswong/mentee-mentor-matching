require 'sequel'
require 'digest'
require 'date'
require 'time_difference'
require_relative '../db/db'
require_relative '../models'

class Authentication < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user

  def validate
    super
    errors.add(:user_id, 'cannot be empty') if user_id.nil?
    errors.add(:salt, 'cannot be empty') if salt.nil? || salt.empty?
    errors.add(:iv, 'cannot be empty') if iv.nil? || iv.empty?
    errors.add(:data_crypt, 'cannot be empty') if data_crypt.nil? || data_crypt.empty?
  end
end
