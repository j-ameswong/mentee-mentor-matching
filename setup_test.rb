require_relative 'models/user'
require 'csv'



name_list = CSV.read("#{__dir__}/gen_db/Customer_Names.csv")
def gen_role(params)
  case params[:username]
  when "user"
    return "mentee"
  when "user1"
    return "mentor"
  when "admin"
    return "admin"
  else
    Random.rand < 0.25 ? "mentor" : "mentee"
  end
end

name_list[1..100].each do |row|
  params = {}
  params.merge! :username => (row[0] + row[1])[0..8].downcase
  params.merge! :email => params[:username] + "@sheffield.ac.uk"
  params.merge! :role => gen_role(params)
  params.merge! :password => params[:username]
  params.merge! :confirm_password => params[:password]
  params.merge! :terms => "terms_accepted"
  params[:role] == "mentee" ? params.merge!(:year_of_study => 1) :
    params.merge!(:year_of_study => 2 + (Random.rand * 2).round)
  params.merge! :date_of_birth => (Date.today - 365*(18 + Random.rand * 6)).to_s
  params.merge! :first_name => row[0]
  params.merge! :last_name => row[1].tr("0-9", "")

  user = User.new
  user.signup(params)
end

User.all.each do |user|
  @approved = false
  if user.admin?
    user.authentication.update(:password => "admin", :confirm_password => "admin", :approved => true)
    user.authentication.save
    @approved = true
  elsif user.username == "user" || user.username == "user1"
    user.authentication.update(:approved => true)
    user.authentication.save
    @approved = true
  elsif rand < 0.4
    user.authentication.update(:approved => true)
    user.authentication.save
    @approved = true
  end

  if @approved && !user.admin?
    params = {:id => user.id, :first_name => user.profile.first_name, :last_name => user.profile.last_name,
              :user_languages => [Language.first(language_name: "English").id, rand(Language.count + 1)],
              :user_expertises => [rand(Expertise.count), rand(Expertise.count)],
              :date_of_birth => user.profile.date_of_birth, :nationality => rand(Nationality.count),
              :bio_brief => "This is a brief bio", :bio_detailed => "This is a detailed bio",
              :availability => true, :user_id => user.id}

    user.profile.update(params)
    user.profile.save
    if user.mentor?
      user.mentor_profile.update(params)
      user.mentor_profile.save
    end
    if user.mentee?
      user.mentee_profile.update(params)
      user.mentee_profile.save
    end

    UserLanguage.create!(params)
    UserExpertise.create!(params)
  end
end

MenteeProfile.where(availability: true).each do |profile|
  if rand < 0.5
    profile.created_at = profile.created_at - 8.days
    profile.update(:role => "mentee", :availability => true)
    profile.save
  end
end

puts "\nSuccessfully generated DB!"


