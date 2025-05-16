require_relative 'models/user'
require 'csv'

params = {}
params.merge! :username => "admin"
params.merge! :email => params[:username] + "@sheffield.ac.uk"
params.merge! :role => "admin"
params.merge! :password => params[:username]
params.merge! :confirm_password => params[:password]
params.merge! :terms => "terms_accepted"
params.merge! :date_of_birth => (Date.today - 365*(18 + Random.rand * 6)).to_s
params.merge! :first_name => "Ad"
params.merge! :last_name => "Min"

user = User.new
user.signup(params)
user.authentication.update(:password => "admin", :confirm_password => "admin", :approved => true)
user.authentication.save

puts "\nSuccessfully generated DB!"


