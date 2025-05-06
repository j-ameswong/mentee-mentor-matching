get "/flags" do
  redirect "/login" unless session[:logged_in]

  erb :flaggedAccounts
end