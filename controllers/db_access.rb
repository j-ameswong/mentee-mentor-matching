require_relative '../app'
require_relative '../models/user'

users = User.select(:id).map(:id)
puts "Found!" if users.inspect.include? 998960510.to_s


#puts User.gen_uid('1119406c9491')
# check_user_password = User.where(email_address: )