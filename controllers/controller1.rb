get "/" do
  redirect "/login" unless session["logged_in"]
  erb :index
end

get "/account" do
  redirect "/login" unless session["logged_in"]
  erb :account
end

get "/login" do
  erb :login
end

get "/signup" do
  erb :signup
end

get "/matches" do
  redirect "/login" unless session["logged_in"]
  erb :matches
end

get "/profile" do
  redirect "/login" unless session["logged_in"]
  erb :profile
end

get "/support" do
  redirect "/login" unless session["logged_in"]
  erb :support
end

get "/example" do
  redirect "/login" unless session["logged_in"]
  erb :example
end

get "/suspension" do
    erb :suspension
end

get "/deleted-account" do
    erb :accountDeleted
end