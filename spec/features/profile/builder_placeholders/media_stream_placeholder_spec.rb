require 'rails_helper'

describe 'Media placeholder' do
  let(:profile) { create(:candidate_profile) }
  let(:account) { create :account, profile: profile }
  let!(:medium) { create(:medium, profile: profile, position: position) }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
  end

  describe 'show media' do
    let(:position) { 1 }

    specify do
      expect(page).to have_css '#media'
      expect(page).to have_no_content 'Add Photos Into Stream'
    end
  end

  describe 'show placeholder' do
    let(:position) { nil }

    specify do
      expect(page).to have_content 'Add Photos Into Stream'
      expect(page).to have_no_css '#media'
    end
  end
end
