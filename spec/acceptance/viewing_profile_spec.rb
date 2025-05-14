# 2.1. Mentees can browse available mentors before matching.
# Mentee
  # 1. Mentees can view a list of available mentors (based on their capacities), including their years of study and expertise.
  # 2. Mentor names, pictures, and contact details are hidden before matching.
  # 3. Mentees can report a mentor’s profile if it is inappropriate.
require "rspec"

RSpec.describe "Profile Viewing" do

  context "Contact details are only visible to matched users" do
    it "allows matched users to see each others' contact details" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user"
      fill_in "Password", with: "user"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/matches"

      visit "/logout"
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/matches"
    end

    it "doesn't show users' contact details if not matched with the viewer" do

    end
  end
end
# 2.2. Mentees need to write a description before submitting a mentor preference.
# Mentee
  # 1. When submitting preferred mentors, mentees must enter a justification (max 100 words) in a text box.
  # 2. The submit button remains disabled until the text box contains content.
  # 3. After submitting, the mentee’s application is added to the mentor’s selection panel.
# 2.3. Mentors can view mentee applications and accept matches.
# Mentor
  # 1. Mentors have access to a list of mentees who applied to them and who are on a waiting list.
  # 2. Mentors can view each mentee’s public profile and application text, if any, before selection However, mentors cannot see the mentee's name, profile picture, or contact details before matching.
  # 3. Mentors can accept, decline, or report a mentee application.
# 2.4. Matched mentors become unavailable for further selection.
# Mentor, Mentee
  # 1. Once a mentor reaches their capacity, their profile is no longer available to new mentees immediately.
  # 2. The mentees who have expressed their preference to the mentor receive a notification that the mentor becomes unavailable.
# 2.5. Unmatched mentees move to a waiting list after one week.
# Mentee
  # 1. Mentees who were not paired with a mentor for a week are moved to a waiting list visible to all available mentors.
  # 2. If there are no available mentors in the system, unpaired mentees are immediately moved to the waiting list.