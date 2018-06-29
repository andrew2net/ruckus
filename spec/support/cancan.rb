RSpec.configure do |config|
  config.before :each, :cancan, type: :controller do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(@controller).to receive(:current_ability).and_return(@ability)
  end
end
