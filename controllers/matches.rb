get "/matches" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?
  redirect "/matches/mentor" if session[:user].mentor?
end

get "/matches/mentee" do
  redirect "/login" unless session[:logged_in]
  @mentors = MentorProfile.where(availability: true)
  erb :menteeMatching
end

post "/matches/mentee" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentor" if session[:user].mentor?

  unless Match.exists?(session[:user].id, params[:mentor_id])
    Match.generate!(params.merge(:mentee_id => session[:user].id))
    puts "Match application created by #{session[:user].id} to #{params[:mentor_id]}"
  end

  redirect "/matches/mentee"
end

get "/matches/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  mentor_id = session[:user].id
  @menteeApplicants = Match.where(mentor_id: mentor_id, status: 'pending')
  @mentees = MenteeProfile.where(availability: true)
  erb :mentorMatching
end

post "/matches/mentor/accept" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" unless session[:user].mentor?

  if params[:mentee_id]
    match = Match.first(mentee_id: params[:mentee_id], mentor_id: session[:user].id, status: 'pending')
    match.activate
  end
  redirect "/matches/mentor"
end