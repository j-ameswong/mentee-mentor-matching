require_relative '../models/user'
require_relative '../db/db'

data = CSV.read("#{__dir__}/../public/resources/expertises.csv")

Expertise.each do |row|
  row.delete
end

data[1..-1].each do |row|
  expertise = Expertise.new
  expertise.category = row[0].strip
  expertise.skill = row[1].strip
  # puts expertise.inspect
  expertise.save
end