require 'spec_helper'

Rails.application.routes.default_url_options[:host] = 'example.com'
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
# If you're not using ActiveRecord, or you'd prefer not to run each of your
# examples within a transaction, remove the following line or assign false
# instead of true.
  config.use_transactional_fixtures = false
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  config.include Rails.application.routes.url_helpers
  config.include FactoryGirl::Syntax::Methods
  config.include ControllersHelper,     type: :controller
  config.include FeaturesHelper,        type: :feature
  config.include BuilderSwitchesHelper, type: :feature
  config.include ModelsHelper,          type: :model
end
