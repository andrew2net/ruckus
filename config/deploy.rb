lock '3.4.0'

set :repo_url, 'git@gl.jetru.by:railsmuffin/ruck.us.git'
set :application, 'Ruck.us'
set :ruby_version,    '2.1.0'
set :user, 'ruckus'

%w(ruck.us win.gop).each do |name|
  server name, user: fetch(:user), roles: [:web, :app, :db], primary: true
end
# comment 3 lines before uncomment line below if you want to run db:pull, don't forget to set proper domain
# server 'win.gop', user: fetch(:user), roles: [:web, :app, :db], primary: true

set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets public/uploads)
set :linked_files, fetch(:linked_files, [])
                     .push(*%w(newrelic analytics application database democracy_engine_credentials google_map_key
                               oauth_providers sidekiq).map { |name| "config/#{name}.yml" })

set :unicorn_pid, -> { File.join(shared_path, 'tmp', 'pids', 'unicorn.pid') }
set :unicorn_config_path, -> { File.join(shared_path, 'config', 'unicorn.rb') }

set :sidekiq_config, -> { "#{shared_path}/config/sidekiq.yml" }


set :real_revision, -> { capture("cd #{current_path} && git rev-parse --short HEAD").chop }
set :current_revision, -> { real_revision }

set :slack_webhook, 'https://hooks.slack.com/services/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'
set :slack_icon_emoji, ':rocket:'

set :db_ignore_data_tables, %w(requests)
set :disallow_pushing, true
set :db_remote_clean, true
set :db_local_clean, true
