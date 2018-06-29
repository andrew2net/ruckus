require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module RuckUs
  class Application < Rails::Application
    config.cells.with_assets = %w(percent media_stream issues ask_question press_events)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
 
    config.to_prepare do
      Devise::Mailer.layout 'mailer'
    end

    config.generators do |g|
      g.orm :active_record
      g.test_framework = :rspec
      g.helper = false
      g.assets = false
    end

    config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)
    config.assets.precompile += %w(*.jpg *.png *.gif *.jpeg)

    config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')

    config.filter_parameters += [:cc_cvv, :cc_number, :cc_month, :cc_year]

    config.i18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.autoload_paths += %W(#{config.root}/app/cells/concerns)

    # Only for donations via HTTPS
    config.middleware.insert_before 0, 'Rack::Cors', logger: -> { Rails.logger } do
      allow do
        origins '*'
        resource /\A\/front\/profiles\/\d+\/donations\z/
      end
    end
  end
end
