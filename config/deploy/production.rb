set :rails_env,   'production'
set :branch,      'master'
set :deploy_to,   -> { "/home/#{fetch(:user)}/apps/ruck.us" }
