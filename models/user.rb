require_relative '../db/db'

# Specify user table, by default it downcases User and adds an s to the end
class User < Sequel::Model
  def self.add_user(id, first_name, last_name, university_email, date_of_birth, password_, acc_type)
    #DB.insert
  end
end