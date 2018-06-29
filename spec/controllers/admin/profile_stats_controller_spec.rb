require 'rails_helper'

describe Admin::ProfilesStatsController do
  let(:admin) { create(:admin) }

  before { sign_in(admin) }

  describe 'GET #index' do
    before { allow_any_instance_of(ProfilesStat).to receive(:export).and_return(report) }
    let(:report) { '1,2,3,4,5,6,7,8,9,0' }

    specify do
      get :index, format: :csv
      expect(response.status).to eq 200
      expect(response.body).to eq report
    end
  end
end
