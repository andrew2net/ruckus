require 'rails_helper'

describe Front::EventsController do
  let!(:profile) { create(:candidate_profile) }
  let!(:event1) { create(:event, profile: profile, start_time: 1.day.from_now) }
  let!(:event2) { create(:event, profile: profile, start_time: 2.months.ago) }
  let!(:event3) { create(:event, profile: profile, start_time: 4.months.ago) }

  before { with_subdomain(profile.domain.name) }

  describe 'GET #index' do
    after do
      expect(assigns(:events)).to_not be_nil
      expect(response).to render_template('index')
    end

    specify 'by month' do
      xhr :get, :index, profile_id: profile.id, event_id: event1.id
    end

    specify 'archive' do
      xhr :get, :index, profile_id: profile.id, archive: true
    end

    specify 'without params' do
      xhr :get, :index, profile_id: profile.id
    end
  end

  describe 'GET #show' do
    let(:params) { { profile_id: profile.id, id: event1.id } }

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
