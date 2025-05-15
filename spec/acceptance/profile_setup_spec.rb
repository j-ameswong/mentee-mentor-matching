require "rspec"

RSpec.describe "Edit Profile" do
  context "Users can upload a profile picture" do
    it "allows uploading a profile picture in accepted formats (PNG, JPG)" do
      # Simulate a user logging in
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      # Simulate uploading a valid PNG file
      visit "/profile/edit"
      attach_file("Upload Profile Picture", "spec/fixtures/profile_picture.png")
      click_button "Save"
      expect(text).to include("User1's Profile")
    end

    it "displays an error message for invalid format" do
      # Simulate a user logging in
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      # Simulate uploading an invalid file format
      visit "/profile/edit"
      attach_file("Upload Profile Picture", "spec/fixtures/profile_picture.webp")
      click_button "Save"
      expect(text).to include("Profile pic is an invalid file format. Please upload a PNG or JPG file.")
    end

    it "displays an error message for oversized file" do
      # Simulate a user logging in
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      # Simulate uploading an oversized file
      visit "/profile/edit"
      attach_file("Upload Profile Picture", "spec/fixtures/oversized_profile_picture.jpg")
      click_button "Save"
      expect(text).to include("Profile pic file size exceeds 5MB limit.")
    end
  end

  context "Users can add a personal background summary and goals" do
    it "allows a user to add a valid personal background summary" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/profile/edit"
      fill_in "Describe yourself briefly:", with: "I really enjoy eating fish and chips."
      fill_in "Describe yourself in detail:", with: "I really enjoy eating fish and chips, and I also like fried chicken."

      click_button "Save"

      expect(page).to have_content("I really enjoy eating fish and chips.")
      expect(page).to have_content("I really enjoy eating fish and chips, and I also like fried chicken.")
    end

    it "provides an error message for invalid brief bio" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/profile/edit"
      fill_in "Describe yourself briefly:", with: "<h1>I really enjoy eating fish and chips.</h1>"
      fill_in "Describe yourself in detail:", with: "I really enjoy eating fish and chips, and I also like fried chicken."

      click_button "Save"

      expect(page).to have_content("bio brief: is invalid")
    end

    it "provides an error message for invalid full bio" do
      visit "/"
      expect(page).to have_content("Sign up instead")

      fill_in "Username", with: "user1"
      fill_in "Password", with: "user1"
      click_button "Log in"
      expect(page).to have_content("Welcome to UniConnect!")

      visit "/profile/edit"
      fill_in "Describe yourself briefly:", with: "I really enjoy eating fish and chips."
      fill_in "Describe yourself in detail:", with: "<p>I really enjoy eating fish and chips, and I also like fried chicken.<p>"

      click_button "Save"

      expect(page).to have_content("bio detailed: is invalid")
    end
  end
end