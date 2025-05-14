get "/support" do
  redirect "/login" unless session[:logged_in]
  params[:type] ? @type = params[:type].to_i : @type = -1
  params[:target_id] ? @target_id = params[:target_id].to_i : @target_id = -1

  erb :support
end

post "/support" do
  params.merge!(:sent_by => session[:user].id)

  errors = {}
  errors[:details] = "Please provide your justification" if params[:details].empty?
  if SupportTicket.first(sent_by: params[:sent_by], target_id: params[:target_id], type: params[:type])
    errors[:exists] = "A pending ticket has already been submitted"
  end

  if errors.empty?
    SupportTicket.create!(params.merge!(:sent_by => session[:user].id))
    redirect "/support"
  else
    @errors = errors
    erb :support
  end
end
