require 'sequel'
require_relative '../models/user.rb'

DB.alter_table :users do
  add_column :year_of_study, String
end

#user = User.first(university_email: 'cawong2@sheffield.ac.uk')

#user.acc_type = 'admin'
#user.save

#User.where(acc_type: nil).delete