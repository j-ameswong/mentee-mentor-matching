require_relative '../app'
require_relative '../models/user.rb'

# this file is for testing the database with ruby sequel commands
#@user = User.new()
user = User.new()
puts user.gen_uid('biuasdnasjkd')
#users = User.select(:id).map(:id)
#puts User.gen_pass_hash(12345677, 'password')


#puts User.gen_uid('1119406c9491')
# check_user_password = User.where(email_address: )