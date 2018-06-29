set :rails_env,   'staging'
set :branch,      'develop'
set :deploy_to,   -> { "/home/#{fetch(:user)}/apps/qa1-ruck.us" }
