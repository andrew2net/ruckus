require 'rails_helper'

describe Profile::BuildersController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'GET #show' do
    it 'can show' do
      get :show
      expect(response.status).to eq 200
    end

    specify 'missing template error' do
      expect { get :show, format: :jpg }.to raise_error ActionController::RoutingError
    end
  end
end
