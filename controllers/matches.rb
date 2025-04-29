get "/matches" do
  @mentors = User.where(acc_type: "mentor")
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?
  redirect "/matches/mentor" if session[:user].mentor?
end

get "/matches/mentee" do
  redirect "/login" unless session[:logged_in]
  erb :menteeMatching
end

post "/matches/mentee" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentor" if session[:user].mentor?

  match = Match.new
  match.generate(params.merge(:mentee_id => session[:user].id))
  puts "Match application created by #{session[:user].id} to #{params[:mentor_id]}"

  redirect "/matches/mentee"
end

get "/matches/mentor" do
  redirect "/login" unless session[:logged_in]
  redirect "/matches/mentee" if session[:user].mentee?

  erb :mentorMatching
end