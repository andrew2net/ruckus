require 'rails_helper'
include Warden::Test::Helpers

describe LandingController do
  describe "GET 'index'" do
    let(:profile) { create :candidate_profile }
    let(:account) { create :account, profile: profile }

    it 'returns http success' do
      get 'index'
      expect(response).to render_template 'index'
    end

    it 'redirects to account root if account is logged in' do
      sign_in account

      get 'index'
      expect(response).to redirect_to profile_root_path
    end
  end
end
