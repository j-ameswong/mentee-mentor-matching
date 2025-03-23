require_relative '../models/user'

printf "> "
choice = gets.chomp

if choice == "1"
  @user = User.new

  params = {:username => "contessa", :email => "contessa@sheffield.ac.uk", :password => "contessa", :password_confirmation => "contessa",
            :role => "mentee", :date_of_birth => (Date.today - 365*20), :first_name => "Arch", :last_name => "Linux"}

  @user.signup(params)
elsif choice == "2"
  printf "> ID: "
  id = gets.chomp.to_i

  User.delete_from_all(id)
end
