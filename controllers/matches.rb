get "/matches" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?
  redirect "/matches/mentor" if session[:user].mentor?
end

get "/matches/mentee" do
  redirect "/login" unless session[:logged_in]

  if session[:user].role == 'mentee'
    user = User.first(id: session[:user].id)  
    mentee_profile = MenteeProfile.first(user_id: user.id) 
    
    if mentee_profile && mentee_profile.availability
      match = Match.first(mentee_id: user.id, status: "active")
      
      if match
        mentor_id = match.mentor_id
        @currentMentor = MentorProfile.first(user_id: mentor_id)
      else
        @currentMentor = nil
      end
    else
      @currentMentor = nil
    end

    erb :menteeMatching
  else
    # If the user is not a mentee, redirect them to the mentor page
    redirect "/matches/mentor"
  end
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

  match = Match.first(mentee_id: params[:mentee_id], mentor_id: session[:user].id, status: "pending")
  if params[:accept]
    if match.nil?
      @error = "Match has already been accepted by another mentor"
      erb :mentorMatching
    else
      # Delete all other applications the mentee made
      Match.where(mentee_id: params[:mentee_id]).exclude(mentor_id: session[:user].id).delete
      match.activate
    end
  elsif params[:decline]
    match.nil? ? puts("Do nothing, mentee is already matched") : match.decline
  elsif params[:report]
    # TODO: report profile
  end

  redirect "/matches/mentor"
end