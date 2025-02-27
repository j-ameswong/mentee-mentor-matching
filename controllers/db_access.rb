require_relative '../app'
require_relative '../models/user'

users = User.all
users.each do |x|
    puts x[:id]
end

puts User.gen_uid('1119406c9491')
# check_user_password = User.where(email_address: )