get "/" do
  redirect "/login" unless session[:logged_in]
  erb :index
end

get "/login" do
  redirect "/" if session[:logged_in]
  erb :login
end

get "/account" do
  redirect "/login" unless session[:logged_in]
  erb :account
end

get "/matches" do
  redirect "/login" unless session[:logged_in]
  erb :matches
end

get "/support" do
  redirect "/login" unless session[:logged_in]
  erb :support
end

get "/example" do
  redirect "/login" unless session[:logged_in]
  erb :example
end

get "/suspension" do
    erb :suspension
end

get "/deleted-account" do
    erb :accountDeleted
end

get "/profile" do
  redirect "/" unless session[:logged_in]
  @user = User[session[:id]]
  erb :profile
end

