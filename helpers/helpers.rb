require_relative "validation"
# Add more "require" statements for your helpers here
module FlashHelpers
  def flash
    session[:flash] ||= {}
  end
end

# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

  # Add your own helper modules to this file
  require_if_exist "helpers/local_helpers"
end

configure do
  enable :sessions unless settings.respond_to?(:sessions)
end

before do
  @flash = session[:flash] || {}
end

after do 
  session[:flash] = nil
end
