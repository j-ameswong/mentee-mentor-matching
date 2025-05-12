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

post "/matches/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" unless session[:user].mentor? || session[:user].admin?
  puts params

  # if is a waitlist mentee, create new match
  if params[:waitlisted_mentee] && User.first(id: params[:mentee_id]).mentee_profile.available?
    if params[:accept]
      Match.generate!(params.merge(:mentor_id => session[:user].id,
                                   :message => "Matched after being put into waitlist"))
      # Delete all other applications the mentee made
      Match.where(mentee_id: params[:mentee_id]).exclude(mentor_id: session[:user].id).delete
      Match.first(mentee_id: params[:mentee_id]).activate
      # TODO: message informing successful match
      redirect "/matches"
    elsif params[:report]
      # TODO: report profile
    end
  elsif params[:mentee_id] && User.first(params[:mentee_id]).mentee_profile.available?
    # if is a regular mentee that applied to this specific mentor
    match = Match.first(mentee_id: params[:mentee_id], mentor_id: session[:user].id, status: "pending")
    if params[:accept]
      # Delete all other applications the mentee made
      Match.where(mentee_id: params[:mentee_id]).exclude(mentor_id: session[:user].id).delete
      match.activate
      # TODO: message informing successful match
    elsif params[:decline]
      match.decline
      # TODO: create message in message table telling mentee he was rejected
    elsif params[:report]
      # TODO: report profile
    end
  else
     @error = "Match has already been accepted by another mentor"
     erb :mentorMatching
  end

  redirect "/matches/mentor"
end