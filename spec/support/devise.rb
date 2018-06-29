RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :feature

  Warden.test_mode!
  Devise.stretches = 1
  #Rails.logger.level = 4
end

RSpec.configuration.before :each, type: :controller do
  request.env['devise.mapping'] = Devise.mappings[:account]
end
