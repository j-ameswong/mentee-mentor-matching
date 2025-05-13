get "/message" do
  redirect "/" unless session[:logged_in]
 
  query = UserMessage.where(received_by: session[:user].id)
  
  if session[:message_filters]
    if session[:message_filters][:username] && !session[:message_filters][:username].empty?
      sender_ids = User.where(Sequel.like(:username, "%#{session[:message_filters][:username]}%")).map(:id)
      query = query.where(sent_by: sender_ids) unless sender_ids.empty?
    end
    
    if session[:message_filters][:read_status] && !session[:message_filters][:read_status].empty?
      read_status = session[:message_filters][:read_status].to_i
      query = query.where(read_status: read_status)
    end
  end
  
  @messages = query.all
  
  erb :messages
end

post "/message" do
  redirect "/" unless session[:logged_in]

  session[:message_filters] = {
    username: params[:username],
    read_status: params[:read_status]
  }
  
  redirect "/message"
end

post "/read/:id" do
  redirect "/" unless session[:logged_in]
  
  user_message = UserMessage.first(id: params[:id], received_by: session[:user].id)
  user_message.update(read_status: 1) if user_message
  
  redirect "/message"
end

post "/unread/:id" do
  redirect "/" unless session[:logged_in]
  
  user_message = UserMessage.first(id: params[:id], received_by: session[:user].id)
  user_message.update(read_status: 0) if user_message
  
  redirect "/message"
end

# post "/read" do
#   redirect "/" unless session[:logged_in]
  
#   user_id = params[:user_id].to_i
#   reasoning = params[:flag_reasoning].strip
  
#   user = User.first(id: user_id)
#   if user && !reasoning.empty?
#     user.flag(reasoning)
#   end
  
#   redirect "/flagging"
# end

# post "/unflag/:id" do
#   redirect "/" unless session[:logged_in] && session[:user].admin?
  
#   user = User.first(id: params[:id].to_i)
#   if user
#     user.unflag
#   end
  
#   redirect "/flagging"
# end

# post "/delete/:id" do
#   redirect "/" unless session[:logged_in] && session[:user].admin?
  
#   user = User.first(id: params[:id].to_i)
#   if user
#     user.delete_from_all
#   end
  
#   redirect "/flagging"
# end