require 'sequel'
require_relative '../models/user.rb'

# DB.alter_table :users do
#  set_column_type(:iv, 'BLOB')
#  set_column_type(:salt, 'BLOB')
#  set_column_type(:data_crypt, 'BLOB')
# end

#user = User.first(university_email: 'cawong2@sheffield.ac.uk')

#user.acc_type = 'admin'
#user.save

user = User.first(university_email: 'johnsmith@email.com')
user.acc_type = 'mentee'
user.save

User.where(acc_type: nil).delete