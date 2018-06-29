set :rails_env,   'staging2'
set :branch,      'develop2'
set :deploy_to,   -> { "/home/#{fetch(:user)}/apps/qa2-ruck.us" }
