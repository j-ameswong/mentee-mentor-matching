require "rspec"

RSpec.describe "Admin oversight" do

  context "Flagging accounts", js: true do
    it "allows admins to flag user accounts" do
      visit "/"
      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/flagging"
      expect(page).to have_content("Flagging")

      fill_in "username", with: "user1"
      click_button "Update Filters"
      expect(page).to have_content("user1@sheffield.ac.uk")
      expect(page).to have_content("Flag")

      click_button "Flag"
      fill_in "Reason for flagging:", with: "Naughty boy"
      click_button "Submit"

      expect(page).to have_content("Flagged")
      click_button "Unflag"
      expect(page).to have_content("Not Flagged")
    end

    it "sends a notification to the flagged user" do
      visit "/"
      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/flagging"
      expect(page).to have_content("Flagging")
      fill_in "username", with: "user1"
      click_button "Update Filters"
      expect(page).to have_content("user1")
      expect(page).to have_content("Flag")
      click_button "Flag"
      fill_in "Reason for flagging:", with: "Naughty boy"
      click_button "Submit"
      expect(page).to have_content("Flagged")
      click_button "Unflag"
      expect(page).to have_content("Not Flagged")

      visit "/logout"

      visit "/"
      fill_in "Username/University Email Address:", with: "user1"
      fill_in "Password:", with: "user1"
      click_button "Log in"

      visit "/message"
      expect(text).to include("Your account has been flagged by an admin due to misconduct")
    end
  end
#   # 5.2. Admins can permanently delete accounts if necessary.
#   # Admin
#   # 1. Admins can access a dedicated section listing flagged accounts requiring action due to repeated violations, non-response to flagging, graduation, or university departure.
#   # 2. Admins can select a specific account for permanent deletion.
#   # 3. A confirmation step is required before proceeding with deletion.
#   # 4. Once confirmed, data erasure is triggered and fully executed.
#   todo # 5. The deleted account is removed from all browsing lists.
#   todo # 6. Affected mentors/mentees receive a notification about the deletion, and their mentor-mentee connection is severed.
  context "Deleting accounts" do
    it "creates deletable user for testing purposes" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      click_link "Sign up instead"
      fill_in "Username", with: "deletable"

      fill_in "first_name", with: "dele"
      fill_in "last_name", with: "table"

      fill_in "Email", with: "dtable@sheffield.ac.uk"
      fill_in "DoB", with: Date.new(2001, 02, 03)

      select "Mentee", from: "role"
      select "Year 1", from: "year_of_study"

      fill_in "password", with: "password123"
      fill_in "confirm_password", with: "password123"

      check "terms"
      click_button "Register"

      expect(page).to have_content("Sign up instead")
    end

    it "allows admins to delete accounts", js: true do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/approvals"

      expect(page).to have_content("dtable@sheffield.ac.uk")
      click_link "Approve"

      visit "/flagging"
      expect(page).to have_content("Flagging & Deletion")

      fill_in "username", with: "deletable"
      click_button "Update Filters"
      expect(page).to have_content("deletable")

      message = accept_confirm do
        click_button("Delete")
      end

      expect(message).to eq("Are you sure you want to delete this user?")
      expect(page).not_to have_content("deletable")
    end
  end
# # 5.3. Admin can manually reassign mentors/mentees in extenuating circumstances.
# # Admin
#   # 1. In extenuating circumstances (e.g., mentors or mentees take Leave of Absence in the middle of the semester), admins can manually (re)assign mentors and mentees.
#   # 2. Admins can select any mentee for reassignment.
#   # 3. Admins can select any available mentor (based on their capacities).
#   # 4. The matching result is notified to the mentor and mentee.
# # 5.4. Admin can set a global maximum number of mentees per mentor.
  context "Admins can manually reassign mentors/mentees in ECs" do
    it "allows admins to reassign mentors/mentees" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/accounts"

      expect(page).to have_content("Accounts Management")

      fill_in "username", with: "user1"
      click_button "Update Filters"
      expect(page).to have_content("user1@sheffield.ac.uk")
    end
  end
# # Admin
#   # 1. Admins set an integer limit for maximum mentees per mentor globally.
#   # 2. The global limit becomes the default capacity for a new mentor.
#   # 3. Each mentor can manually set their own capacity locally, which overrides the global limit.
#   # 4. Admins can update the global maximum mentee limit dynamically.
#   # 5. The updated global limit does not override local limits, if any.
  context "Admins can set a global maximum number of mentees per mentor" do
    it "allows admins to set a global maximum number of mentees per mentor" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/accounts"

      expect(page).to have_content("Accounts Management")

      fill_in "max_matches", with: "5"
      click_button "Update Max Matches"
      expect(page).to have_content("Current Max. Matches: 5")
    end
  end

  context "Admins can apply an experienced badge to fourth year mentors with prior mentoring experience" do
    it "allows admins to apply an experienced badge to fourth year mentors with prior mentoring experience" do
      user = User.where(username: "user1").first
      Match.where(mentor_id: user.id).update(status: "completed")
      MentorProfile.where(user_id: user.id).update(year_of_study: 4)

      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/accounts"

      expect(page).to have_content("Accounts Management")

      fill_in "username", with: "user1"
      click_button "Update Filters"
      expect(page).to have_content("user1@sheffield.ac.uk")
      select "Badge", from: "action"
      click_button "Submit"
      visit "/logout"

      expect(page).to have_content("Sign up instead")
      fill_in "Username/University Email Address:", with: "user1"
      fill_in "Password:", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")
      visit "/profile"
      expect(page).to have_content("Experienced Mentor")
    end
  end
end