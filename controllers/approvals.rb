get "/approvals" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  @unapproved = Authentication.where(approved: false).all

  erb :approvals
end

get "/approvals/approve" do
  redirect "/" unless session[:logged_in] && session[:user].admin?
  @user = User.first(id: params.fetch(:to_approve, ""))

  if @user.nil?
    redirect "/approvals"
  else
    @user.approved = true
    @user.save
    puts "User #{@user.id} has been approved"
  end

  redirect "/approvals"
end

get "/approvals/deny" do
  redirect "/" unless session[:logged_in] && session[:user].role.downcase == "admin"
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

  if @user.nil?
    redirect "/approvals"
  elsif params[:approved] == "deny"
    @user.delete_from_all
    puts "Say goodbye to prospective admin #{@user.id}, he will not be missed"
  else
    @user.authentication.update!(params)
    @user.approved = "true"
    @user.save
    puts "Admin #{@user.id} has been approved"
  end

  @unapproved = User.where(Sequel.|({approved: nil}, {approved: "false"})).all
  erb :approvals
end