# 2.1. Mentees can browse available mentors before matching.
# Mentee
# 1. Mentees can view a list of available mentors (based on their capacities), including their years of study and expertise.
#   2. Mentor names, pictures, and contact details are hidden before matching.
#   3. Mentees can report a mentor’s profile if it is inappropriate.
#   2.2. Mentees need to write a description before submitting a mentor preference.
#     Mentee
# 1. When submitting preferred mentors, mentees must enter a justification (max 100 words) in a text box.
#   2. The submit button remains disabled until the text box contains content.
#   3. After submitting, the mentee’s application is added to the mentor’s selection panel.
#   2.3. Mentors can view mentee applications and accept matches.
#   Mentor
# 1. Mentors have access to a list of mentees who applied to them and who are on a waiting list.
#   2. Mentors can view each mentee’s public profile and application text, if any, before selection However, mentors cannot see the mentee's name, profile picture, or contact details before matching.
# 3. Mentors can accept, decline, or report a mentee application.
# 2.4. Matched mentors become unavailable for further selection.
# Mentor, Mentee
#
#
# 1. Once a mentor reaches their capacity, their profile is no longer available to new mentees immediately.
# 2. The mentees who have expressed their preference to the mentor receive a notification that the mentor becomes unavailable.
# 2.5. Unmatched mentees move to a waiting list after one week.
# Mentee
# 1. Mentees who were not paired with a mentor for a week are moved to a waiting list visible to all available mentors.
# 2. If there are no available mentors in the system, unpaired mentees are immediately moved to the waiting list.


# 3.1. Mentees and mentors can view each other's details after matching.
# Mentor, Mentee
  # 1. Both mentors and mentees can see names, profile pictures, and contact details after being matched.
  # 2. Personal details are unblurred upon successful matching.
# 3.2. Mentees are matched with the first mentor who selects them.
# Mentee
  # 1. Once a mentor selects a mentee, the mentee's profile is no longer visible to other mentors (and removed from the waiting list if the mentee was on the list).
  # 2. Mentees receive a system notification about the match.
  # 3. If another mentor tries to accept the just-paired mentee, the mentor receives an error message.
# 3.3. Mentors can select multiple mentees up to their capacity.
# Mentor
  # 1. Mentors can review mentee applications and make selections.
  # 2. Mentors can choose multiple mentees until they reach capacity.
  # 3. Once capacity is reached, the selection button is disabled.
# 3.4. Duration of the match should be one semester.
# Mentor, Mentee
  # 1. For both mentors and mentees, matches should only last until the end of the semester.

require "rspec"

RSpec.describe "Matching" do

  context ""
end