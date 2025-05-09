require 'sequel'
require_relative '../models/user.rb'
require_relative '../db/db.rb'


DB.alter_table :authentication do
  add_column :flag_reasoning, :text
end

# users = User.where(email: "admin4@sheffield.ac.uk")
# users.each do |user|
#   user.delete
# end

# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete
