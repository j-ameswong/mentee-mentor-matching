get "/" do
  redirect "/login" unless session[:logged_in]
  erb :index
end

get "/support" do
  redirect "/login" unless session[:logged_in]
  erb :support
end

post "/support" do
  "Give the option and details to all admins"
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

get "/terms" do
  erb :terms
end

get "/statements" do
  erb :statements
end