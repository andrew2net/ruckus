require 'rails_helper'

describe Front::IssuesController do
  let!(:profile) { create :candidate_profile }
  let!(:account) { profile.account }
  let!(:issue_category) { create(:issue_category, profile: profile) }
  let!(:issue)   { create :issue, profile: profile, issue_category: issue_category }

  before { with_subdomain(profile.domain.name) }

  specify 'GET new' do
    get :show, profile_id: profile.id, id: issue.id
    expect(response).to render_template('show')
  end

  describe 'GET index' do
    let!(:issue_category2) { create(:issue_category, profile: profile) }
    let!(:issue2) { create(:issue, profile: profile, issue_category: issue_category2) }

    specify 'all' do
      get :index, profile_id: profile.id
      expect(response).to render_template :index
      expect(assigns(:category_id)).to eq :all
    end

    specify 'with category' do
      get :index, profile_id: profile.id, category_id: issue_category.id
      expect(response).to render_template :index
      expect(assigns(:category_id)).to eq issue_category.id.to_s
    end
  end

  describe 'GET #show' do
    let(:params) { { profile_id: profile.id, id: issue.id } }

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
