not_found do
  redirect "/404"
end

error do
  redirect "/500"
end

get "/404" do
  @title = "404 Not Found"
  @main_title = "404 Not Found"
  @content = <<~HTML
  <p>Sorry, the page you are looking for does not exist.</p>
  <p>Please check the URL or return to the <a href="/">home page</a>.</p>
HTML

  erb :"/common/errors"
end

get "/500" do
  @title = "500 Unknown Internal Error"
  @main_title = "500 Unknown Internal Error"
  @content = <<~HTML
  <p>Sorry, there was an unknown internal error.</p>
  <p>Please try again later or return to the <a href="/">home page</a>.</p>
HTML

  erb :"/common/errors"
end

