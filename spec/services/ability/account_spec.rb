require 'rails_helper'
require 'cancan/matchers'

describe Account do
  let(:admin) { create :account, profile_id: profile.id }
  let(:editor) { create :account, profile_id: profile.id }
  let(:different_account) { create(:candidate_profile).account }

  before do
    profile.accounts << admin
    profile.accounts << editor

    profile.ownerships.where(account_id: editor.id).update_all type: 'EditorOwnership'
  end

  describe 'premium account' do
    let(:profile) { create(:candidate_profile, :premium) }

    context 'owner signed in' do
      let(:ability) { Ability.new(admin) }

      specify 'Create' do
        expect(ability).to be_able_to(:create, Account.new, profile)
      end

      specify 'Destroy' do
        expect(ability).to be_able_to(:destroy, editor, profile)
        expect(ability).not_to be_able_to(:destroy, admin, profile)
        expect(ability).not_to be_able_to(:destroy, different_account, profile)
      end

      specify 'Update Ownership Type' do
        expect(ability).to be_able_to :update_ownership_type, editor, profile
      end
    end

    context 'editor signed in' do
      let(:ability) { Ability.new(editor) }

      specify 'Create' do
        expect(ability).not_to be_able_to(:create, Account.new, profile)
      end

      specify 'Destroy' do
        expect(ability).not_to be_able_to(:destroy, admin, profile)
        expect(ability).not_to be_able_to(:destroy, editor, profile)
        expect(ability).not_to be_able_to(:destroy, different_account, profile)
      end

      specify 'Update Ownership Type' do
        expect(ability).not_to be_able_to :update_ownership_type, editor, profile
      end
    end
  end

  describe 'free account' do
    let(:profile) { create :candidate_profile, credit_card_holder: nil }
    let(:ability) { Ability.new(admin) }

    specify 'Create' do
      expect(ability).not_to be_able_to(:create, Account, profile)
    end

    specify 'Destroy' do
      expect(ability).not_to be_able_to(:destroy, editor, profile)
    end

    specify 'Update Ownership Type' do
      expect(ability).not_to be_able_to :update_ownership_type, editor, profile
    end
  end
end
