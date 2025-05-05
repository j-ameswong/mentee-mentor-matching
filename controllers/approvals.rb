get "/approvals" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  @unapproved = Authentication.where(approved: false).all
  @filter = !params[:filter].nil? ? params[:filter] : "all"
  puts "Filter is: " + @filter

  erb :approvals
end

get "/approvals/approve" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  @user = User.first(id: params.fetch(:to_approve, ""))

  if @user.nil?
    redirect "/approvals"
  else
    @user.authentication.update!(:approved => true)
    @user.authentication.save
    puts "User #{@user.id} has been approved"
  end

  redirect "/approvals"
end

get "/approvals/deny" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  @user = User.first(id: params.fetch(:to_deny, ""))

  if @user.nil?
    redirect "/approvals"
  else
    puts "Say goodbye to user #{@user.id}, he will not be missed"
    @user.delete_from_all
  end

  redirect "/approvals"
end

post "/approvals" do
  redirect "/" unless session[:logged_in] && session[:user].admin?

  @user = User.first(id: params[:id])
  params[:approved] = (params[:approved] == "approve")

  if @user.nil?
    redirect "/approvals"
  elsif params[:approved]
    @user.authentication.update!(params)
    @user.authentication.save
    puts "Admin #{@user.id} has been approved"
  else
    puts "Say goodbye to prospective admin #{@user.id}, he will not be missed"
    @user.delete_from_all
  end

  @unapproved = Authentication.where(approved: false).all
  erb :approvals
end

post "/approvals/filter" do
  redirect "/" unless session[:logged_in] && session[:user].admin?

  puts params
  redirect "/approvals?filter=#{params["filter-accounts"]}"
end