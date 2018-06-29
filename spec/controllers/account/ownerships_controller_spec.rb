require 'rails_helper'

describe Account::OwnershipsController do
  let!(:profile)     { create :candidate_profile }
  let!(:card_holder) { create :credit_card_holder, profile: profile }
  let!(:account)     { create :account, profile: profile }
  let!(:account2)    { create :account }
  let!(:ownership1)  { create :ownership, profile: profile, account: account }

  before do
    profile.accounts << account2
    account2.ownerships.where(profile_id: profile.id).update_all type: 'EditorOwnership'

    sign_in account
  end

  describe 'GET edit' do
    check_authorizing { get :edit, profile_id: profile.id, account_id: account2.id }

    specify do
      get :edit, profile_id: profile.id, account_id: account2.id
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH update' do
    check_authorizing { patch :update, profile_id: profile.id, account_id: account2.id }

    specify 'success' do
      patch :update, profile_id: profile.id, account_id: account2.id, ownership: { type: 'AdminOwnership' }

      expect(account2.admin_ownerships.where(profile_id: profile.id)).to exist
      expect(account2.editor_ownerships.where(profile_id: profile.id)).not_to exist
      expect(account.editor_ownerships.where(profile_id: profile.id)).to exist
      expect(account.admin_ownerships.where(profile_id: profile.id)).not_to exist

      expect(response).to redirect_to account_profiles_path
    end
  end
end
