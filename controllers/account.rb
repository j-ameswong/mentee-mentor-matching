get "/account" do
  redirect "/login" unless session[:logged_in]
  erb :account
end

get "/account/changepassword" do
  redirect "/login" unless session[:logged_in]

  session[:user].first_time_login = "false" if session[:user].first_time_login == "true"
  session[:user].save
  erb :changepassword
end

post "/account/changepassword" do
  redirect "/login" unless session[:logged_in]
  @user = session[:user]
  @user.errors.add["new_password", "Password cannot be blank"] if params[:new_password].empty?
  @user.errors.add("confirm_password", "Password cannot be blank") if params[:old_password].empty?
  @user.errors.add("new_password", "Passwords cannot be the same") if params[:new_password] == params[:old_password]
  @user.errors.add("confirm_password", "Passwords must match") if params[:new_password] != params[:confirm_password]

  if @user.login({ "password" => params[:old_password] })
    @user.hash_pass(params[:new_password])
    @user.save
    puts "Password changed for #{@user.university_email}"
  end

  erb :changepassword
end