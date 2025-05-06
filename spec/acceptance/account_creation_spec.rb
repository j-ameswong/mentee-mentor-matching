# 1.1. A user can sign up for a mentee/mentor account using a username, email, and password.
# Mentor, Mentee
  # 1. Users can choose to sign up as a mentee (only for the 1st-year students) or mentor (only for 2nd/3rd/4th-year students).
  # 2. Users must create an account with a unique username, email, and password.
  # 3. The system validates all required fields and displays errors for missing fields.
  # 4. The email address must be in a valid format; otherwise, an error message will appear.
  # 5. The system ensures username uniqueness, displaying an error message if it already exists.
  # 6. Upon successful account creation, users are redirected to the profile creation page.
  # 7. Mentor/mentee accounts require admin verification before login and start creating their profiles.
#
# 1.2. Users must acknowledge Terms & Conditions during signup.
# Mentor, Mentee
  # 1. A Terms & Conditions page appears during the signup process.
  # 2. Users must check a box confirming they have read and agreed to the T&C.
  # 3. The system prevents users from proceeding without checking the confirmation box.
  # 4. Upon submission, users can complete the signup process.
#
# 1.3. Admin can create an account through a separate webpage.
# Admin
  # 1. A prospective admin requests the creation of a new admin account with a preferred email.
  # 2. An existing admin creates a new admin account with the received email and a temporary password.
  # 3. The new admin email/password is securely shared with a new admin offline (to avoid sending emails in Codio).
  # 4. The new admin can change their password upon the first successful login.
#
# 1.4. Once an account is approved, users can log in using their credentials.
  # Mentor, Mentee, Admin
  # 1. Users can log in as mentees, mentors, or admins.
  # 2. The system validates credentials, displaying relevant error messages for incorrect inputs.
  # 3. After successful login, users are directed to their respective a dashboard.