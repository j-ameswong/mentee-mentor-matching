require_relative "../models/user"
require_relative "../db/db"

data = CSV.read("#{__dir__}/../public/resources/country.csv")

Nationality.each do |ct|
  ct.delete
end

data[1..-1].each do |row|
  ct = Nationality.new
  ct.country_code = row[0].strip
  ct.country_name = row[1].strip
  # puts ct.inspect
  ct.save
end