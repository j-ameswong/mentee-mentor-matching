# clears the database of all users except the admin
def spec_before
  for user in User.all
    # keeps an admin, mentee and mentor account on test_db for use in testing
    unless user.username == "admin" || user.username == "user" || user.username == "user1"
      # wipes all other data
      user.delete_from_all
    end
  end
end