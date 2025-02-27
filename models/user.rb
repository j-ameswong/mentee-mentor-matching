require_relative '../db/db'

# Specify user table, by default it downcases User and adds an s to the end
class User < Sequel::Model
  def self.add_user(options = {})
    id = options.fetch(:id, 00000000)
    first_name = options.fetch(:first_name, nil) 
    last_name = options.fetch(:last_name, nil) 
    university_email = options.fetch(:university_email, nil)
    date_of_birth = options.fetch(:date_of_birth, nil)
    password_ = options.fetch(:password_, nil)
    acc_type = options.fetch(:acc_type, nil)
    
    DB[:users].insert(id: id, first_name: first_name, last_name: last_name, university_email: university_email, date_of_birth: date_of_birth, password_: password_, acc_type: acc_type)
  end

  def self.check_id_exists(id)
    return false if DB[:users].first(id: id).nil?
    return true
  end

  def self.gen_pass_hash(id, pass = 12345678)
    user = DB[:users].first(id: id)

    password = (Digest::SHA256.hexdigest ('salt' + user + last_name + date_of_birth[counter] + pass))
  end

  def self.gen_uid(pass)
    idd = ''
    unique = false
    all_ids = DB[:users][:id]

    counter = 0
    while not unique
      (0..8).each do |x|
        idd += (pass[x].ord + counter).to_s[-1] 
      end

      unique = true if not all_ids.include? idd
      counter += 1
    end
    
    if idd[0] == 0
      idd[0] = 1
    end
    #if idd.length < 9
    #  idd = idd + '0'* (9 - idd.length) 
    #end
    return idd
  end
end