get "/support" do
  redirect "/login" unless session[:logged_in]
  params[:type] ? @type = params[:type].to_i : @type = -1
  params[:target_id] ? @target_id = params[:target_id].to_i : @target_id = -1

  erb :support
end

post "/support" do
  "Give the option and details to all admins"

  #puts params
  SupportTicket.create!(params.merge!(:sent_by => session[:user].id))
  redirect "/support"
end
