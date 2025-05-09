require_relative '../db/db'

class Expertise < Sequel::Model
  one_to_many :user_expertise, key: :expertise_id
end