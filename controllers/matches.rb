get "/matches" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?
  redirect "/matches/mentor" if session[:user].mentor?
end

get "/matches/matched" do
  if session[:user].mentor?
    redirect "/matches/matched/mentor"
  else
    redirect "/"
  end
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

get "/matches/matched/mentor" do 
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  mentor_id = session[:user].id
  @mentees = Match.where(mentor_id: mentor_id, status: 'active')
  erb :mentorMatchingMatches
end

post "/matches/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" unless session[:user].mentor? || session[:user].admin?
  #puts params

  # if is a waitlist mentee, create new match
  if params[:waitlisted_mentee] && session[:user].mentor_profile.available? && User.first(id: params[:mentee_id]).mentee_profile.available?
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
  elsif params[:mentee_id] && session[:user].mentor_profile.available? && User.first(params[:mentee_id]).mentee_profile.available?
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
     @error = "Match has already been accepted by another mentor or mentee limit exceeded"
     erb :mentorMatching
  end

  redirect "/matches/mentor"
end