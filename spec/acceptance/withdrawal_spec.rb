#4.1 Mentee can request to withdraw from a mentor, providing reasons visible to their mentor.
# Mentee
  # 1. Mentees must submit a withdrawal request with a justification.
  # 2. If no justification is provided, the system displays an error message preventing submission.
  # 3. The withdrawal request is visible to the mentor and admins.
# 4.2. Mentor can request to withdraw from a mentee, providing reasons visible to their mentee.
# Mentor
  # 1. Mentors must submit a withdrawal request with a justification.
  # 2. If no justification is provided, the system displays an error message preventing submission.
  # 3. The withdrawal request is visible to the mentee and admins.
# 4.3. Admin needs to approve or deny withdrawal requests.
# Admin
  # 1. Admins can approve withdrawal requests for mentors or mentees.
  # 2. Admins can deny withdrawal requests, in which case the mentor-mentee connection remains unchanged.
# 4.4. Mentor and mentee accounts are updated after approved withdrawals.
# Mentor, Mentee
  # 1. Upon approval, the mentor-mentee connection is severed, the mentor and mentee are notified, and they can no longer access the other's detailed profile.
  # 2. The mentee count for the mentor decreases by one. If the mentor does not reach their capacity due to the decrease, they become available for new mentees.
  # 3. The mentee can apply for a new mentor, except for the previously severed one.