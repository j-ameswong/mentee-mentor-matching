get "/support" do
  redirect "/login" unless session[:logged_in]
  params[:type] ? @type = params[:type].to_i : @type = -1
  params[:target_id] ? @target_id = params[:target_id].to_i : @target_id = -1

  erb :support
end

post "/support" do
  redirect "/login" unless session[:logged_in]
  params.merge!(:sent_by => session[:user].id)

  errors = {}
  errors[:details] = "Please provide your justification" if params[:details].empty?
  if SupportTicket.first(sent_by: params[:sent_by], target_id: params[:target_id], type: params[:type], is_resolved: false)
    errors[:exists] = "A pending ticket has already been submitted"
  end

  if errors.empty?
    SupportTicket.create!(params.merge!(:sent_by => session[:user].id))
    redirect "/support"
  else
    @errors = errors
    params[:type] ? @type = params[:type].to_i : @type = -1
    params[:target_id] ? @target_id = params[:target_id].to_i : @target_id = -1
    erb :support
  end
end

post "/support/decision" do
  redirect "/login" unless session[:logged_in]
  redirect "/" unless session[:user].admin?

  ticket = SupportTicket.first(id: params[:ticket_id])

  case ticket.type
  when SupportTicket.withdraw?
    if params[:approve]
      if ticket.sent_by_user.mentor?
        match = Match.first(mentor_id: ticket.sent_by, mentee_id: ticket.target_id, status: "active")
        match.cancel
        ticket.resolve
      elsif ticket.sent_by_user.mentee?
        match = Match.first(mentee_id: ticket.sent_by, status: "active")
        match.cancel
        ticket.resolve
      end
    elsif params[:deny]
      ticket.resolve
    end
  when SupportTicket.report?
    if params[:dismiss]
      ticket.resolve
    elsif params[:flag]
      session[:flag_filters] ||= {}
      session[:flag_filters][:username] = ticket.target_id_user.usernametr br
      redirect "/flagging"
    end
  end

  redirect "/support/admin" if ticket.is_resolved
end

get "/support/admin" do
  redirect "/login" unless session[:logged_in]
  redirect "/support" if (session[:user].mentor? || session[:user].mentee?)

  @filter = !params[:filter].nil? ? params[:filter] : "all"
  @tickets = SupportTicket.where(is_resolved: false)
  erb :adminSupport
end

post "/support/filter" do
  redirect "/" unless session[:logged_in] && session[:user].admin?

  filter = params["filter-accounts"]
  redirect "/support/admin?filter=#{params["filter-accounts"]}"
end