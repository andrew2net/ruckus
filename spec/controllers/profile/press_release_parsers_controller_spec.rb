require 'rails_helper'

describe Profile::PressReleaseParsersController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'POST #create' do
    check_authorizing { post :create }

    specify 'success' do
      allow(PressReleaseParser).to receive(:new) do
        OpenStruct.new(scrape: {
          title:      'title',
          page_title: 'page_title',
          page_date:  Time.now.strftime('%d %B %Y'),
          url:        'http://example.com/example'
        }, valid?: true, images: [])
      end

      post :create, press_release: { url: 'http://example.com/example' }, format: :js

      expect(flash.now[:notice]).to eq 'URL was parsed successfully'
      expect(response).to render_template :create
    end

    specify 'failure' do
      allow(PressReleaseParser).to receive(:new) do
        OpenStruct.new(scrape: { title: '', page_title: '', page_date: '', url: '' },
                       valid?: false,
                       images: [])
      end

      post :create, press_release: { url: 'http://example.com/example' }, format: :js

      expect(response).to render_template :create
    end
  end
end
