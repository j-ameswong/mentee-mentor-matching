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

# data = CSV.read("./Customer_Names.csv")

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

    date_of_birth[counter] = (1998 + rand(9)).to_s + '/' + month + '/' + day
    password_[counter] = (Digest::SHA256.hexdigest ('salt' + row[0] + row[1] + date_of_birth[counter]))[0..11]

    r = rand()
    if r < 0.3
      acc_type[counter] = 'mentor'
    else
      acc_type[counter] = 'mentee'
    end

    idd = ''
    unique = false
    while not unique
      (0..8).each do |x|
        idd += password_[counter][x].ord.to_s[-1]
      end
      if not id.include? idd
        unique = true
      end
    end
    id[counter] = idd

    counter = counter + 1
  end

  combined_data = [id, first_name, last_name, university_email, date_of_birth, password_, acc_type]
  return(combined_data)
end

# gen_new(data).each do |x|
#   puts x.to_s
# end

def write_to_csv(combined_data)
  CSV.open("./mentormentee.csv", "wb") do |csv|
    csv << ['id', 'first_name', 'last_name', 'university_email', 'date_of_birth', 'password_', 'acc_type']
    (0...combined_data[0].length).each do |i|
      csv << [combined_data[0][i], combined_data[1][i], combined_data[2][i], combined_data[3][i], combined_data[4][i], combined_data[5][i], combined_data[6][i]]
    end
  end
end

# write_to_csv(gen_new(data))

def gen_test_db(path)
  DB = Sequel.sqlite(path)

  DB.create_table? :user do
    primary_key :id
    String :first_name
    String :last_name
    String :university_email
    String :date_of_birth
    String :password_
    String :acc_type
  end

  users = DB[:user]
  data = CSV.read("./mentormentee.csv")

  data[1..-1].each do |row|
    users.insert(id: row[0], first_name: row[1], last_name: row[2], university_email: row[3], 
                date_of_birth: row[4], password_: row[5], acc_type: row[6])
  end
end