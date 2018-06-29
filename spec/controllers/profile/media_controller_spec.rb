require 'rails_helper'

describe Profile::MediaController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in(account) }

  describe 'GET #index' do
    check_authorizing { get :index }

    specify do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'DELETE #destroy' do
    let(:medium) { create(:medium, profile: profile) }
    let(:destroyer_class) { Media::Destroyer }

    check_authorizing { delete :destroy, id: medium.id, format: :js }

    specify do
      expect(destroyer_class).to receive(:new).with(medium).and_call_original
      expect_any_instance_of(destroyer_class).to receive(:process)

      delete :destroy, id: medium.id, format: :js
      expect(response).to render_template :destroy
    end
  end
end
