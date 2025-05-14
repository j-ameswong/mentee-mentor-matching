get "/support" do
  redirect "/login" unless session[:logged_in]
  erb :support
end

post "/support" do
  "Give the option and details to all admins"

  SupportTicket.create!(params.merge(sent_by: session[:user].id))
  redirect "/support"
end
