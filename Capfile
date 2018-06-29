require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano3/unicorn'
require 'capistrano/sidekiq'
require 'capistrano/rails'
require 'slackistrano'
require 'capistrano-db-tasks'
require 'sshort'
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

after 'deploy:publishing', 'unicorn:duplicate'
