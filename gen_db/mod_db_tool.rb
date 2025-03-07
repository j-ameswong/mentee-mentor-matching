require 'sequel'
require_relative '../models/user.rb'

DB.alter_table :users do
  add_column :username, String
end

#user = User.first(university_email: 'bruhmoment@sheffield.ac.uk')

#user.profile_pic = ''
#user.save

#User.where(acc_type: nil).delete