require_relative '../app'

users = User.all
users.each do |user|
  puts user.password_
end