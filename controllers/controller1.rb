get "/" do
  # redirect "/login" unless session["logged_in"]
  erb :index
end

get "/account" do
  erb :account
end

get "/login" do
  erb :login
end

get "/signup" do
  erb :signup
end

get "/matches" do
  erb :matches
end

get "/profile" do
  erb :profile
end

get "/support" do
  erb :support
end

get "/example" do
  erb :example
end

# post "/login" do
#   @username = params.fetch("username", "")
#   @password = params.fetch("password", "")
#   @error = nil

#   if @username == "user" && @password == "pass"
#     session["logged_in"] = true
#     redirect erb :index
#   else
#     @error = "Username/Password combination incorrect"
#   end

#   erb :login
# end

# get "/logout" do
#   session.clear
#   erb :logout
# end