require 'rails_helper'

describe Profile::PreviewProfilesController do
  let(:profile1)    { create :candidate_profile }
  let(:profile2)    { create :candidate_profile }
  let(:account1)    { create :account, profile: profile1 }
  let!(:ownership1) { create :ownership, profile: profile1, account: account1}
  let(:account2)    { create :account, profile: profile2 }

  before { sign_in account1 }

  describe 'GET show' do
    specify 'success' do
      get :show, id: profile1.id
      expect(response).to render_template 'accounts/show'
    end

    specify 'failure' do
      expect { get :show, id: account2.profile.id }.to raise_error ActionController::RoutingError
    end
  end
end
