get "/matches" do
  @mentors = User.where(acc_type: "mentor")
  redirect "/login" unless session[:logged_in]
  erb :matches
end