get "/flagging" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  query = User
  
  if session[:flag_filters]
    if session[:flag_filters][:username] && !session[:flag_filters][:username].empty?
      query = query.where(Sequel.like(:username, "%#{session[:flag_filters][:username]}%"))
    end
    
    if session[:flag_filters][:role] && !session[:flag_filters][:role].empty?
      query = query.where(role: session[:flag_filters][:role])
    end
  end
  
  @users = query.all
  
  if session[:flag_filters] && session[:flag_filters][:flag_status] && !session[:flag_filters][:flag_status].empty?
    flag_status = session[:flag_filters][:flag_status] == "1"
    @users = @users.select { |user| user.flagged? == flag_status }
  end
  
  erb :flagging
end

post "/flagging" do
  redirect "/" unless session[:logged_in] && session[:user].admin?

  session[:flag_filters] = {
    username: params[:username],
    role: params[:role],
    flag_status: params[:flag_status]
  }
  
  redirect "/flagging"
end

post "/flag" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  
  user_id = params[:user_id].to_i
  reasoning = params[:flag_reasoning].strip
  
  user = User.first(id: user_id)
  if user && !reasoning.empty?
    user.flag(reasoning)
  end
  
  redirect "/flagging"
end

post "/unflag/:id" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  
  user = User.first(id: params[:id].to_i)
  if user
    user.unflag
  end
  
  redirect "/flagging"
end

post "/delete/:id" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  
  user = User.first(id: params[:id].to_i)
  if user
    user.delete_from_all
  end
  
  redirect "/flagging"
end

