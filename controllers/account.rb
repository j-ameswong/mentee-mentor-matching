get "/account" do
  redirect "/login" unless session[:logged_in]
  erb :account
end

get "/account/changePassword" do
  redirect "/login" unless session[:logged_in]

  session[:user].authentication.update(:first_time_login => false)
  session[:user].authentication.save
  erb :changePassword
end

post "/account/changePassword" do
  redirect "/login" unless session[:logged_in]
  @user = session[:user]
  @user.errors.clear

  if @user.authentication.login({ :password => params[:old_password] })
    @user.authentication.update(params.merge!(:password => params[:new_password]))

    if @user.authentication.valid?
      @user.authentication.save
      @success = true
      puts "Password changed for #{@user.id}"
    end
  end

  @user.errors.merge!(@user.authentication.errors)
  erb :changePassword
end