require 'sequel'
require_relative '../models/user.rb'

DB.alter_table :users do
  set_column_type(:iv, 'BLOB')
  set_column_type(:salt, 'BLOB')
  set_column_type(:data_crypt, 'BLOB')
end
#DB[:data_crypt].set_column_type('BLOB')
#DB[:salt].set_column_type('BLOB')