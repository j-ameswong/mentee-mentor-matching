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

post "/login" do
  @username = params.fetch("email-address", "")
  @password = params.fetch("password", "")
  @error = nil

  if @username == "johnsmith@email.com" && @password == "pass"
    session["logged_in"] = true
    redirect "/"
  else
    @error = "Username/Password combination incorrect"
  end

  erb :login
end

get "/logout" do
  session.clear
  erb :logout
end

get "/suspension" do
    erb :suspension
end

get "/deleted-account" do
    erb :accountDeleted
end