get "/" do
  redirect "/login" unless session[:logged_in]
  erb :index
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