# clears the database of all users except the admin
def spec_before
  for user in User.all
    unless user.username == "admin"
      user.delete_from_all
    end
  end
end