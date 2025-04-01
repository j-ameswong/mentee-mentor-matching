get "/matches" do
  @mentors = User.where(acc_type: "mentor")
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?
  redirect "/matches/mentor" if session[:user].mentor?
end

get "/matches/mentee" do
  erb :menteeMatching
end

get "/matches/mentor" do
  erb :mentorMatching
end