Dir["../../models/*.rb"].each do |file|
  require file
end

new_db = Sequel.connect("sqlite://#{__dir__}/../db_test.sqlite3")

old_users = OldUser.select_all

old_users.each do |old_user|
  puts old_user.inspect

  User.create(
    id: old_user[:id],
    username: old_user[:username],
    email: old_user[:university_email],
    role: old_user[:acc_type],
  )

  Authentication.create(
    user_id: old_user[:id],
    iv: old_user[:iv],
    salt: old_user[:salt],
    data_crypt: old_user[:data_crypt],
  )

  Profile.create(
    user_id: old_user[:id],
    first_name: old_user[:first_name],
    last_name: old_user[:last_name],
    nationality: old_user[:nationality],
    date_of_birth: old_user[:date_of_birth],
    gender: old_user[:gender],
  )
end

