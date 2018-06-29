unless %w(development test).include?(Rails.env)
  Airbrake.configure do |config|
    config.api_key = YAML.load_file(Rails.root.join('config', 'airbrake.yml'))['airbrake_api_key'][Rails.env]
    config.host    = 'errbit.railsmuffin.co'
    config.port    = 80
    config.secure  = config.port == 443
  end
end
