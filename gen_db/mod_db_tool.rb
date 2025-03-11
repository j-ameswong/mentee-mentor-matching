require 'sequel'
require_relative '../models/user.rb'

#DB.alter_table :users do
#  add_column :first_time_login, String
#end

user = User.first(university_email: "user@sheffield.ac.uk")
puts user.year_of_study
user.year_of_study = "Year 1"
puts user.year_of_study
user.save

#user.save
#user.delete
#user.profile_pic = ''
#user.save

#User.where(acc_type: nil).delete