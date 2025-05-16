require "rspec"

RSpec.describe "Matching" do
  user = User.where(username: "user").first
  user1 = User.where(username: "user1").first
  auth = Authentication.where(user_id: user.id).first
  auth1 = Authentication.where(user_id: user1.id).first
  auth[:flagged] = false
  auth[:flag_reasoning] = nil
  auth.update(:first_time_login => false)
  auth1[:flagged] = false
  auth1[:flag_reasoning] = nil
  auth1.update(:first_time_login => false)
  auth.save
  auth1.save

  context "Mentees can report a mentor's profile if it is inappropriate", js: true do
    it "allows mentees to report a mentor's profile" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user"
      fill_in "Password", with: "user"
      click_button "Log in"

      visit "/matches"
      expect(page).to have_content("user1")
      click_button "Report"
      fill_in "help-request", with: "This profile is inappropriate."
      click_button "Submit"

      visit "/logout"
      expect(page).to have_content("Sign up instead")
      fill_in "Username", with: "admin"
      fill_in "Password", with: "admin"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/support/admin"
      expect(page).to have_content("This profile is inappropriate.")
    end
  end

  context "Contact details are only visible to matched users", js: true do
    it "doesn't show users' contact details if not matched with the viewer" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user"
      fill_in "Password", with: "user"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/matches"
      expect(text).to include("user1")
      expect(page).not_to have_content("University Email: user1@sheffield.ac.uk")

      visit "/logout"

      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/matches/mentor"
      expect(page).not_to have_content("University Email: user1@sheffield.ac.uk")
    end
  end
end