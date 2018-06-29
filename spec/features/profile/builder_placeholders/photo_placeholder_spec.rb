require 'rails_helper'

describe 'Photo placeholder' do
  let!(:profile) { create :candidate_profile, photo: photo }
  let!(:account) { create :account, profile: profile }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
  end

  describe 'showing photo' do
    let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'photo.jpg')) }
    specify { expect(page).to have_css '.account-image' }
  end

  describe 'show placeholder' do
    let(:photo) { nil }

    specify do
      expect(page).to have_css '.account-image-add'
      expect(page).to have_content 'Add Profile Image'
    end
  end
end
