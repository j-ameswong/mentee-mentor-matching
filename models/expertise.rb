require_relative '../db/db'

class Expertise < Sequel::Model
  one_to_one :user_expertise
end