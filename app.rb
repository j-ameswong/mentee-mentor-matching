# Gems
require "require_all"
require "sinatra"
require "./app"

# Set up public folder
set :public_folder, __dir__ + '/public'

# Bootstrapping method to only require files/whole directories if they exist
def require_if_exist(file_path)
  abs_file_path = File.expand_path(file_path, __dir__)

  if File.file?("#{abs_file_path}.rb")
    require abs_file_path
  elsif File.directory?(abs_file_path)
    require_all abs_file_path
  end
end

# Require application files and directories
require_if_exist "helpers/helpers"
require_if_exist "models/user.rb"
require_if_exist "db/db.rb" #changed to db.rb because it didn't work for me without it for some reason
require_if_exist "controllers"

# Sessions
enable :sessions
