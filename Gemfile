source 'http://rubygems.org'

gem 'rails', '~> 4.1.8'

gem 'pg'
gem 'seedbank'
gem 'jquery-rails'
gem 'jquery-datatables-rails'
gem 'font-awesome-rails'
gem 'kaminari'
gem 'enumerize'
gem 'email_validator'
gem 'mechanize'
gem 'draper'
gem 'jquery-cookie-rails'
gem 'cells'
gem 'mixpanel-ruby'
gem 'sidekiq-scheduler'
gem 'tld'
gem 'paranoia', '2.1.0'
gem 'attr_encrypted'
gem 'byebug'
gem 'sprockets'
# charts
gem 'morrisjs-rails'
gem 'raphael-rails'

gem 'haml-rails'
gem 'simple_form'
gem 'remotipart'
gem 'nested_form'
gem 'carrierwave'
gem 'mini_magick'
gem 'active_link_to'
gem 'has_scope'
gem 'show_for'
gem 'friendly_id'
gem 'watu_table_builder', require: 'table_builder'
gem 'possessive'

#authentications
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'koala'
gem 'twitter'
gem 'devise'
gem 'devise_invitable'
gem 'cancancan'

# video thumbnails
gem 'yt'
gem 'vimeo'

gem 'inherited_resources', github: 'josevalim/inherited_resources'
gem 'geocoder'

gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 3.0.3.0'

gem 'airbrake'
gem 'newrelic_rpm' # need newrelic.yml from NewRelic
gem 'figaro'

#background jobs
gem 'sidekiq', '>= 3'
gem 'sidetiq'
gem 'sidekiq-failures'
gem 'sidekiq-status'
gem 'sinatra', '>= 1.3.0', require: nil

# card processing
gem 'httparty'

# registration steps
gem 'aasm'

# Only for donations via HTTPS
gem 'rack-cors', require: 'rack/cors'

group :development do
  gem 'puma'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'annotate'
  gem 'bullet'
  gem 'letter_opener'
  gem 'rails_dt'
end

gem 'execjs'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier'
gem 'jquery-ui-rails'

group :test do
  gem 'rspec-rails', '~> 3.0.2'
  gem 'rspec-instafail'
  gem 'shoulda'
  gem 'capybara', '~> 2.4'
  gem 'capybara-puma'
  gem 'capybara-screenshot'
  gem 'capybara-webkit', '~> 1.3.0'
  gem 'launchy'
  gem 'fuubar', '~> 2.0.0'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock', '= 1.8.0'
  gem 'test_after_commit'
  gem 'timecop'
  gem 'rspec-cells'
end

group :development, :test do
  gem 'ffaker'
  gem 'factory_girl_rails'
  gem 'pry-rails'
  #gem 'sqlite3'
  gem 'pry-byebug'
end

group :tools do
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano_colors'
  gem 'sshort'
  gem 'capistrano3-unicorn', require: false
  gem 'capistrano-sidekiq'
  gem 'slackistrano'
  gem 'capistrano-db-tasks', github: 'sgruhier/capistrano-db-tasks', require: false
end

group :production do
  gem 'unicorn'
end
