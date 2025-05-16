# Helper method for safe message sending
def send_match_notification(sent_by, received_by, message_type)
  begin
    UserMessage.send_message(
      sent_by: sent_by,
      received_by: received_by,
      message_type: message_type
    )
  rescue => e
    puts "Error sending match notification (#{message_type}): #{e.message}"
  end
end

def check_match_end
  # Check for match end
  return session[:user].mentee_matches.first.check_end if session[:user].mentee? && Match.first(mentee_id: session[:user].id, status: "active")

  if session[:user].mentor? && Match.first(mentor_id: session[:user].id, status: "active")
    session[:user].mentor_matches.each do |match|
      return match.check_end if match.status == "active"
    end
  end

  false
end

get "/matches" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?
  redirect "/matches/mentor" if session[:user].mentor?

  #redirect "/matches" if check_match_end
end

get "/matches/matched" do
  redirect "/login" unless session[:logged_in]

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

    check_match_end ? (redirect "/matches") : (erb :menteeMatching)
  end
end

post "/matches/mentee" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentor" if session[:user].mentor?

  unless Match.exists?(session[:user].id, params[:mentor_id])
    if Match.generate!(params.merge(:mentee_id => session[:user].id))
      puts "Match application created by #{session[:user].id} to #{params[:mentor_id]}"

      send_match_notification(
        session[:user].username,
        params[:mentor_id],
        'match_pending'
      )
      redirect "/matches/mentee"
    else
      @error = "Match failed or word count exceeded 100, please try again"
      erb :menteeMatching
    end
  end
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
  redirect "matches/matched/mentor" if !session[:user].mentor_profile.below_limit?  


  mentor_id = session[:user].id

  @menteeApplicants = Match.where(mentor_id: mentor_id, status: 'pending')
  @mentees = MenteeProfile.where(availability: true)

  check_match_end ? (redirect "/matches") : (erb :mentorMatching)
end

post "/matches/matched/mentee" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentor" if session[:user].mentor?

  target_id = params[:target_id]
  if params[:report]
    redirect "/support?target_id=#{target_id}&type=#{TicketType.first(name: "report").id}"
  elsif params[:withdrawal]
    redirect "/support?target_id=#{target_id}&type=#{TicketType.first(name: "withdrawal").id}"
  else
    redirect "/matches/mentee"
  end
end

get "/matches/matched/mentor" do 
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  mentor_id = session[:user].id
  @mentees = Match.where(mentor_id: mentor_id, status: 'active')

  check_match_end ? (redirect "/matches") : (erb :mentorMatchingMatches)
end

post "/matches/matched/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  target_id = params[:target_id]
  if params[:report]
    redirect "/support?target_id=#{target_id}&type=#{SupportTicket.report?}"
  elsif params[:withdrawal]
    redirect "/support?target_id=#{target_id}&type=#{SupportTicket.withdraw?}"
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
      send_match_notification(
        session[:user].username,
        params[:mentee_id],
        'match_success'
      )
      send_match_notification(
        "System",
        session[:user].id,
        'match_success'
      )
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
      UserMessage.send_message(
        sent_by: session[:user].username,
        received_by: params[:mentee_id],
        message_type: 'match_success'
      )
      UserMessage.send_message(
        sent_by: "System",
        received_by: session[:user].id,
        message_type: 'match_success'
      )
    elsif params[:decline]
      match.decline
      # TODO: create message in message table telling mentee he was rejected
      UserMessage.send_message(
        sent_by: session[:user].username,
        received_by: params[:mentee_id],
        message_type: 'match_declined'
      )
    elsif params[:report]
      # TODO: report profile
      send_match_notification(
        session[:user].username,
        params[:mentee_id],
        'report'
      )
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

  session[:user].mentor_profile.update(:max_matches => params[:mentor_max_mentees], :availability => true)
  session[:user].mentor_profile.save

  #puts session[:user].mentor_profile.inspect
  redirect "/matches/matched/mentor"
end
