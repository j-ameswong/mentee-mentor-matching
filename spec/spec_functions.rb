def spec_before
  # before each suite of tests, reset the test database
  User.all.each { |user|
    # keeps an admin, mentee and mentor account on test_db for use in testing
    if user.username == "admin" || user.username == "user" || user.username == "user1"
      # wipes all other data
      auth = Authentication.where(user_id: user.id).first
      unless auth.nil?
        auth[:flagged] = false
        auth[:flag_reasoning] = nil
        auth.save
        puts "Unflagged user #{user.username}"
      end
      puts "Kept user #{user.username}"
    else
      # wipes all other data
      user.delete_from_all
    end
  }
end