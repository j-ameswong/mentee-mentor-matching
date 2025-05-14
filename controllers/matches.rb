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
  redirect "/matches/mentor" if session[:user].mentor?

  if session[:user].mentee?
    user = session[:user]
    mentee_profile = user.mentee_profile
    match = Match.first(mentee_id: user.id, status: "active")

    if mentee_profile && match
      @currentMentor = match.mentor
    end

    erb :menteeMatching
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

post "/matches/mentee/report" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentor" if session[:user].mentor?

  target_id = params[:target_id]
  redirect "/support?target_id=#{target_id}&type=#{TicketType.first(name: "report").id}"
end

get "/matches/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  mentor_id = session[:user].id
  @menteeApplicants = Match.where(mentor_id: mentor_id, status: 'pending')
  @mentees = MenteeProfile.where(availability: true)
  erb :mentorMatching
end

post "/matches/matched/mentee" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentor" if session[:user].mentor?

  target_id = params[:target_id]
  if params[:report]
    redirect "/support?target_id=#{target_id}&type=#{TicketType.first(name: "report").id}"
  elsif params[:withdrawal]
    redirect "/matches/matched/withdrawal"
  else
    redirect "/matches/mentee"
  end
end

get "/matches/matched/mentor" do 
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  mentor_id = session[:user].id
  @mentees = Match.where(mentor_id: mentor_id, status: 'active')
  erb :mentorMatchingMatches
end

post "/matches/matched/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  target_id = params[:target_id]
  if params[:report]
    redirect "/support?target_id=#{target_id}&type=#{TicketType.first(name: "report").id}"
  elsif params[:withdrawal]
    redirect "/matches/matched/withdrawal"
  else
    redirect "/matches/matched/mentor"
  end
end

post "/matches/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" unless session[:user].mentor? || session[:user].admin?
  #puts params
  @menteeApplicants = Match.where(mentor_id: session[:user].id, status: 'pending')
  @mentees = MenteeProfile.where(availability: true)
  puts session[:user].mentor_profile.below_limit?

  # if is a waitlist mentee, create new match
  if params[:waitlisted_mentee] && session[:user].mentor_profile.below_limit? && User.first(id: params[:mentee_id]).mentee_profile.available?
    if params[:accept]
      Match.generate!(params.merge(:mentor_id => session[:user].id,
                                   :message => "Matched after being put into waitlist"))
      # Delete all other applications the mentee made
      Match.where(mentee_id: params[:mentee_id]).exclude(mentor_id: session[:user].id).delete
      Match.first(mentee_id: params[:mentee_id], mentor_id: session[:user].id, status: "pending").activate
      # TODO: message informing successful match
      redirect "/matches"
    elsif params[:report]
      # TODO: report profile
    end
  elsif params[:mentee_id] && session[:user].mentor_profile.below_limit? && User.first(id: params[:mentee_id]).mentee_profile.available?
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
  end

  redirect "/matches/mentor" unless @error
  erb :mentorMatching if @error
end

post "/matches/mentor/report" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentor" unless session[:user].mentor? || session[:user].admin?

  target_id = params[:target_id]
  redirect "/support?target_id=#{target_id}&type=#{TicketType.first(name: "report").id}"
end

post "/matches/mentor/set-max" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches" unless session[:user].mentor? || session[:user].admin?

  session[:user].mentor_profile.update(:max_matches => params[:mentor_max_mentees])
  session[:user].mentor_profile.save

  #puts session[:user].mentor_profile.inspect
  redirect "/matches/mentor"
end