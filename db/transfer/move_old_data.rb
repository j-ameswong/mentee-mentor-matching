Dir["../../models/*.rb"].each do |file|
  require file
end

old_users = OldUser.select_all
genders = ["male", "female"]

old_users.each do |old_user|
  puts old_user.inspect

  user = User.new

  user.id = old_user[:id]
  user.username = old_user[:username]
  user.email = old_user[:university_email]
  user.role = old_user[:acc_type]

  user.save


  Authentication.create(
    user_id: old_user[:id],
    iv: old_user[:iv],
    salt: old_user[:salt],
    data_crypt: old_user[:data_crypt],
    approved: old_user[:approved] == "true",
    first_time_login: old_user[:first_time_login] == "true"
  )

  Profile.create(
    user_id: old_user[:id],
    first_name: old_user[:first_name],
    last_name: old_user[:last_name],
    nationality: old_user[:nationality],
    date_of_birth: old_user[:date_of_birth],
    gender: genders.sample, # old_user[:gender],
    profile_picture: old_user[:profile_pic],
    bio_brief: old_user[:description],
    # bio_detailed:
  )

  if old_user[:languages] != nil
    old_user[:languages].split(",").each do |language|
      UserLanguage.create(
        user_id: old_user[:id],
        language: language
      )
    end
  end

  if old_user[:acc_type] == "mentor"
    MentorProfile.create(
      user_id: old_user[:id],
      year_of_study: old_user[:year_of_study],
      num_matches: 0,
      max_matches: 3,
      # badges
    )

    # UserExpertise.create(
    # )
  end

  if old_user[:acc_type] == "mentee"
    MenteeProfile.create(
      user_id: old_user[:id],
      availability: true
    )
  end

end

