get "/approvals" do
  redirect "/" unless session[:logged_in] && session[:user].role == "admin"
  @unapproved = User.where(Sequel.|({approved: nil}, {approved: "false"})).all

  erb :approvals
end

get "/approvals/approve" do
  redirect "/" unless session[:logged_in] && session[:user].role == "admin"
  @user = User.first(id: params.fetch("to_approve", ""))

  if @user.nil?
    redirect "/approvals"
  else
    @user.approved = "true"
    @user.save
    puts "User #{@user.id} has been approved"
  end

  redirect "/approvals"
end

get "/approvals/deny" do
  redirect "/" unless session[:logged_in] && session[:user].role.downcase == "admin"
  @user = User.first(id: params.fetch("to_deny", ""))

  if @user.nil?
    redirect "/approvals"
  else
    @user.delete
    puts "Say goodbye to user #{@user.id}, he will not be missed"
  end

  redirect "/approvals"
end

post "/approvals" do
  redirect "/" unless session[:logged_in] && session[:user].role.downcase == "admin"

  temp_pass = params.fetch("temp_password", "").strip
  @user = User.first(id: params.fetch("id", ""))
  approval = params.fetch("approved", "")

  if @user.nil?
    redirect "/approvals"
  elsif approval != "approve"
    @user.delete
    puts "Say goodbye to prospective admin #{@user.id}, he will not be missed"
  elsif temp_pass.empty?
    @user.errors.add "temp_password", "is empty"
  else
    @user.hash_pass(temp_pass)
    @user.approved = "true"
    @user.save
    puts "User #{@user.id} has been approved"
  end

  @unapproved = User.where(Sequel.|({approved: nil}, {approved: "false"})).all
  erb :approvals
end