require 'sequel'
require_relative '../models/user.rb'

DB.alter_table :expertises do
  drop_column :expertise_name
  add_column :category, String
  add_column :skill, String
end

# users = User.where(email: "admin4@sheffield.ac.uk")
# users.each do |user|
#   user.delete
# end

# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete
