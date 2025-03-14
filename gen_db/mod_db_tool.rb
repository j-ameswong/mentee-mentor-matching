require 'sequel'
require_relative '../models/user.rb'

DB.alter_table :users do
  set_column_type :year_of_study, String
end

# users = User.where(university_email: "admin4@sheffield.ac.uk")
# users.each do |user|
#   user.delete
# end

# User.where(acc_type: nil).delete
# User.where(acc_type: nil).delete
# User.where(acc_type: nil).delete
# User.where(acc_type: nil).delete
