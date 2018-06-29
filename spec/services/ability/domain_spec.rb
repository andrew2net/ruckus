require 'rails_helper'
require 'cancan/matchers'

describe Domain do
  describe 'free account' do
    let(:profile) { create :candidate_profile, :free }
    let(:account) { create :account, profile: profile }
    let(:ability) { Ability.new(account) }

    specify do
      expect(ability).not_to be_able_to(:manage, Domain)
      expect(ability).to be_able_to(:index, Domain)
    end
  end

  describe 'premium account' do
    let(:profile) { create :candidate_profile, :premium }
    let(:account) { create :account, profile: profile }
    let(:ability) { Ability.new(account) }

    specify { expect(ability).to be_able_to(:manage, Domain) }
  end
end
