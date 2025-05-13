# 1.5. Users can upload profile details and additional information.
# Mentor, Mentee
  # 1. Users can upload a profile picture in accepted formats (PNG, JPG).
  # 2. If an invalid format or oversized file (> 5MB) is uploaded, an error message appears.
  # 3. Users can add a personal background summary and goals.
  # 4. Contact details are only visible to matched users.
  # 5. Users must successfully save all profile details before proceeding.
require "rspec"

RSpec.describe "Edit Profile" do
  context "Users can upload a profile picture" do
    it "allows uploading a profile picture in accepted formats (PNG, JPG)" do
      # Simulate a user logging in
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user"
      fill_in "Password", with: "user"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      # Simulate uploading a valid PNG file
      visit "/profile/edit"
      attach_file("Upload Profile Picture", "spec/fixtures/profile_picture.png")
      click_button "Save"
      expect(page).to have_content("User's Profile")
    end

    it "displays an error message for invalid format" do
      # Simulate a user logging in
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user"
      fill_in "Password", with: "user"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      # Simulate uploading an invalid file format
      visit "/profile/edit"
      attach_file("Upload Profile Picture", "spec/fixtures/profile_picture.webp")
      click_button "Save"
      expect(text).to include("profile_pic error; invalid file format. Please upload a PNG or JPG file.")
    end

    it "displays an error message for oversized file" do
      # Simulate a user logging in
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user"
      fill_in "Password", with: "user"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      # Simulate uploading an oversized file
      visit "/profile/edit"
      attach_file("Upload Profile Picture", "spec/fixtures/oversized_profile_picture.jpg")
      click_button "Save"
      expect(page).to have_content("profile_pic error; file size exceeds 5MB limit.")
    end
  end
end