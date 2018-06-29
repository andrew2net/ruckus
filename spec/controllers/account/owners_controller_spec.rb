require 'rails_helper'

describe Account::OwnersController, :pending do
  # asking client if this is needed
  let!(:profile) { create :candidate_profile }
  let!(:card_holder) { create :credit_card_holder, profile: profile }
  let!(:account) { profile.account }
  let!(:account2) { create :account }

  before do
    profile.accounts << account2
    sign_in account
  end

  describe 'PATCH update' do
    # check_authorizing { patch :update, profile_id: profile.id, id: account2.id }

    specify 'success' do
      xhr :patch, :update, profile_id: profile.id, id: account2.id
      expect(profile.reload.owner_id).to eq account2.id

      expect(response).to render_template :update
    end
  end
end
