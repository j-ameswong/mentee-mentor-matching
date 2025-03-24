require_relative './models/user'

printf "> "
choice = gets.chomp

if choice == "1"
  @user = User.new

  params = {:username => "contessa", :email => "contessa@sheffield.ac.uk", :password => "contessa1", :confirm_password => "contessa1",
            :role => "mentor", :terms => "terms_accepted", :year_of_study => "2", :date_of_birth => (Date.today - 365*20).to_s, :first_name => "Arch", :last_name => "Linux"}

  @user.signup(params)
elsif choice == "2"
  printf "> ID: "
  id = gets.chomp.to_i

  User.delete_from_all(id)
end

User.where(username: "contessa").each do |user|
  user.delete_from_all
end