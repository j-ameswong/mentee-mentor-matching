=begin
id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    university_email TEXT,
    date_of_birth TEXT,
    password_ TEXT, 
    acc_type TEXT)
=end
require "csv"
require "digest"
require "sequel"
require_relative '../models/user.rb'
require 'openssl'

data = CSV.read("#{__dir__}/Customer_Names.csv")
data_test = CSV.read("#{__dir__}/../public/resources/country.csv")

puts data_test.length

def gen_new(data)
  id = []
  first_name = []
  last_name = []
  university_email = []
  date_of_birth = []
  password_ = []
  acc_type = []

  counter = 0
  data[1..-1].each do |row|
    first_name[counter] = row[0]
    last_name[counter] = row[1]
    university_email[counter] = (row[0] + row[1])[0..6].downcase + '@sheffield.ac.uk'

    month = rand(13)
    if month == 2
      day = rand(29)
    elsif [1,3,5,7,8,10,12].include? month
      day = rand(32)
    else
      day = rand(31)
    end

    if month<10
      month = '0' + month.to_s
    else
      month = month.to_s
    end

    if day<10
      day = '0' + day.to_s
    else
      day = day.to_s
    end

    date_of_birth[counter] = (1998 + rand(9)).to_s + '-' + month + '-' + day

    r = rand()
    if r < 0.3
      acc_type[counter] = 'mentor'
    else
      acc_type[counter] = 'mentee'
    end

    idd = ''
    unique = false
    count = 0
    while not unique
      (0..8).each do |x|
        idd += (password_[counter][x].ord + count).to_s[-1]
      end
      if not id.include? idd
        unique = true
      else
        count += 1
      end
    end

    if idd.length < 9
      idd = idd + '0'* (9 - idd.length) 
    end
    id[counter] = idd

    counter = counter + 1
  end

  combined_data = [id, first_name, last_name, university_email, date_of_birth, password_, acc_type]
  return(combined_data)
end

def gen_profile(data, uname)
  user = User.new
  rand_user = (rand() * data.length).to_i
  
  first_name = data[rand_user][0]
  last_name = data[rand_user][1]

  #username = (first_name + last_name)[0..6].downcase
  username = uname

  email = username.downcase + '@sheffield.ac.uk'

  id = user.gen_uid

  date_of_birth = Date.today - (18*365 + rand(7*365))

  if username == "admin"
    acc_type = 'admin'
  elsif username == "user"
    acc_type = 'mentee'
    year_of_study = 1
  elsif username == "user1"
    acc_type = 'mentor'
    year_of_study = 2
  elsif rand() < 0.3
    acc_type = 'mentor'
    year_of_study = 1 + rand(4)
  else
    acc_type = 'mentee'
    year_of_study = 1
  end

  params = {
  "id" => id,
  "username" => username,
  "password" => username,
  "confirm_password" => username,
  "university_email" => email,
  "date_of_birth" => date_of_birth,
  "first_name" => first_name,
  "last_name" => last_name,
  "acc_type" => acc_type,
  "year_of_study" => year_of_study,
  "approved" => true,
  "first_time_login" => true
  }

  user.signup(params)
  user.save
end

def write_to_csv(combined_data)
  CSV.open("./mentormentee.csv", "wb") do |csv|
    csv << ['id', 'first_name', 'last_name', 'university_email', 'date_of_birth', 'password_', 'acc_type']
    (0...combined_data[0].length).each do |i|
      csv << [combined_data[0][i], combined_data[1][i], combined_data[2][i], combined_data[3][i], combined_data[4][i], combined_data[5][i], combined_data[6][i]]
    end
  end
end

#write_to_csv(gen_new(data))

def gen_test_db(path)
  db = Sequel.sqlite(path)

  db.create_table? :users do
    Integer primary_key :id
    String :first_name
    String :last_name
    String :university_email
    String :date_of_birth
    BLOB :iv
    BLOB :salt
    BLOB :data_crypt
    String :acc_type
    BLOB :profile_pic
    String :languages
    String :year_of_study
    String :approved
    String :nationality
  end
end

starting_users = ["admin", "user1", "user2"]
starting_users.each do |user|
  gen_profile(data, user)
end