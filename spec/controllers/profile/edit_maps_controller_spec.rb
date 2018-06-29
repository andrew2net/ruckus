require 'rails_helper'

describe Profile::EditMapsController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'GET #show' do
    it 'can see' do
      get :show
      expect(response).to render_template :show
    end
  end
end
