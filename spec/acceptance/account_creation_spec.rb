require "rspec"

RSpec.describe "Account creation" do

  context "when signing up as a mentee" do
    it "allows the user to create an account with valid credentials" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      click_link "Sign up instead"
      fill_in "Username", with: "menteeUser"

      fill_in "first_name", with: "Mentee"
      fill_in "last_name", with: "User"

      fill_in "Email", with: "menteemail@sheffield.ac.uk"
      fill_in "DoB", with: Date.new(2001, 02, 03) \

        select "Mentee", from: "role"
      select "Year 1", from: "year_of_study"

      fill_in "password", with: "password123"
      fill_in "confirm_password", with: "password123"

      check "terms"
      click_button "Register"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/approvals"

      expect(page).to have_content("menteemail@sheffield.ac.uk")
    end

    it "requires an admin to approve the account" do
      visit "/"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/approvals"

      expect(page).to have_content("menteemail@sheffield.ac.uk")

      click_link "Approve"

      expect(page).not_to have_content("menteemail@sheffield.ac.uk")
    end
  end

  context "when signing up as a mentor" do
    it "allows the user to create an account with valid credentials" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      click_link "Sign up instead"
      fill_in "Username", with: "mentorUser"

      fill_in "first_name", with: "Mentor"
      fill_in "last_name", with: "User"

      fill_in "Email", with: "mentormail@sheffield.ac.uk"
      fill_in "DoB", with: Date.new(2001, 02, 03)

      select "Mentor", from: "role"
      select "Year 2", from: "year_of_study"

      fill_in "password", with: "password123"
      fill_in "confirm_password", with: "password123"

      check "terms"
      click_button "Register"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/approvals"

      expect(page).to have_content("mentormail@sheffield.ac.uk")
    end

    it "requires an admin to approve the account" do
      visit "/"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/approvals"

      expect(page).to have_content("mentormail@sheffield.ac.uk")

      click_link "Approve"

      expect(page).not_to have_content("mentormail@sheffield.ac.uk")
    end
  end

  context "when signing up with an existing username" do
    it "displays an error message" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      click_link "Sign up instead"
      fill_in "Username", with: "mentorUser"

      fill_in "first_name", with: "Mentor"
      fill_in "last_name", with: "User"

      fill_in "Email", with: "secondmentormail@sheffield.ac.uk"
      fill_in "DoB", with: Date.new(2001, 02, 03)

      select "Mentor", from: "role"
      select "Year 2", from: "year_of_study"

      fill_in "password", with: "password123"
      fill_in "confirm_password", with: "password123"

      check "terms"
      click_button "Register"

      expect(page).to have_content("already exists")
    end
  end

  context "when logging in as a mentee for the first time" do
    it "redirects the user to fill out profile details" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "menteeUser"
      fill_in "Password", with: "password123"

      click_button "Log in"

      expect(page).to have_content("Edit Menteeuser's Profile")
    end
  end

  context "when signing up without accepting T&C" do
    it "displays an error message" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      click_link "Sign up instead"
      fill_in "Username", with: "newMenteeUser"
      fill_in "first_name", with: "Mentee"
      fill_in "last_name", with: "User"
      fill_in "Email", with: "newmenteemail@sheffield.ac.uk"
      fill_in "DoB", with: Date.new(2001, 02, 03)
      select "Mentee", from: "role"
      select "Year 1", from: "year_of_study"
      fill_in "password", with: "password123"
      fill_in "confirm_password", with: "password123"
      # Do not check the terms and conditions box
      click_button "Register"

      expect(page).to have_content("Terms and Conditions must be accepted")
    end
  end

  context "when signing up" do
    it "allows user to read Ts&Cs" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      click_link "Sign up instead"

      expect(page).to have_content("By signing up, you agree to our Terms & Conditions")

      click_link "By signing up, you agree to our Terms & Conditions"

      expect(page).to have_content("TERMS AND CONDITIONS")
    end
  end

  context "when signing up as an admin" do
    it "allows the user to request to create an account with valid credentials" do
      visit "/signup/admin"
      expect(page).to have_content("Sign up for new admin account")

      fill_in "University Email:", with: "adminUser"

      fill_in "Email", with: "adminmail@sheffield.ac.uk"

      check "terms"

      click_button "Register"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")
      visit "/approvals"

      expect(page).to have_content("adminmail@sheffield.ac.uk")
    end

    it "requires an admin to approve the account" do
      visit "/"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "admin"
      fill_in "Password:", with: "admin"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")

      visit "/approvals"

      expect(page).to have_content("adminmail@sheffield.ac.uk")

      fill_in "Temporary Password", with: "temporarypassword"
      fill_in "Confirm Temporary Password", with: "temporarypassword"

      select "Approve", from: "approved"
      click_button "Submit"
    end
  end

  context "Once account has been approved" do
    it "allows mentees to log in with valid credentials" do
      visit "/"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "menteeUser"
      fill_in "Password:", with: "password123"
      click_button "Log in"

      expect(page).to have_content("Welcome to UniConnect!")
    end

    it "allows mentors to log in with valid credentials" do
      visit "/"

      expect(page).to have_content("Sign up instead")

      fill_in "Username/University Email Address:", with: "mentorUser"
      fill_in "Password:", with: "password123"
      click_button "Log in"

      expect(page).to have_content("Home")
    end
  end
end