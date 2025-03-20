require 'sequel'
require_relative '../models/user.rb'

DB.alter_table :users do
  add_column :description, String
end

# users = User.where(university_email: "admin4@sheffield.ac.uk")
# users.each do |user|
#   user.delete
# end

# User.where(acc_type: nil).delete
# User.where(acc_type: nil).delete
# User.where(acc_type: nil).delete
# User.where(acc_type: nil).delete
