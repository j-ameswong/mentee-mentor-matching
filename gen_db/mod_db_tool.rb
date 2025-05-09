require 'sequel'
require_relative '../models/user.rb'
require_relative '../db/db.rb'


#DB.alter_table :mentor_profiles do
  # drop_column :expertise_name
#add_column :availability, :boolean
#DB.alter_table :authentication do
  # add_column :flag_reasoning, :text
#end

users = User.where(username: "luqman")
users.each do |user|
  user.delete_from_all
end

# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete
