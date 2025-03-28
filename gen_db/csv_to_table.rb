require_relative "../models/user"
require_relative "../db/db"

data = CSV.read("#{__dir__}/../public/resources/languages.csv")

Language.each do |lang|
  lang.delete
end

data[1..-1].each do |row|
   lang = Language.new
   lang.language_name = row[3].strip
   lang.native_name = row[4].split(",")[0].strip
   lang.language_code = row[0].strip
   #puts lang.inspect
   lang.save
end