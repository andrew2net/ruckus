require 'rails_helper'

describe Front::SocialPostsController do
  let!(:profile) { create(:candidate_profile) }
  let!(:account) { profile.account }
  let!(:social_post) { create(:social_post, profile: profile) }

  before { with_subdomain(profile.domain.name) }

  describe 'GET #show' do
    let(:params) { { profile_id: profile.id, id: social_post.id } }

    specify 'from our site' do
      get :show, params
      expect(response).to render_template 'show'
    end

    context 'from facebook' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:referrer).and_return('facebook.com')
      end

      specify 'from our site' do
        get :show, params
        expect(response).to redirect_to "http://#{profile.domain.name}.example.com/"
      end
    end
  end
end
