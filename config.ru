# This file is used by Rack-based servers to start the application.
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
