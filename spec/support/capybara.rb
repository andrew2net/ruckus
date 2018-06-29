require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'

Capybara.configure do |config|
  config.javascript_driver = :webkit
  config.default_wait_time = 20
  config.match = :prefer_exact
end
