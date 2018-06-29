require 'rails_helper'

describe Front::PressReleasesController do
  let(:profile) { create(:candidate_profile) }

  describe '#index' do
    let!(:press_release1) { create(:press_release, profile: profile, position: 1) }
    let!(:press_release2) { create(:press_release, profile: profile, position: 2) }
    let!(:press_release3) { create(:press_release, profile: profile, position: 3) }

    specify do
      xhr :get, :index, profile_id: profile.id
      expect(response).to render_template 'index'
      expect(assigns :press_releases).to eq [press_release3, press_release2, press_release1]
    end
  end
end
