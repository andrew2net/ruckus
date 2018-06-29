require 'rails_helper'

describe 'Builder popups', :js do
  let(:profile)  { create :candidate_profile }
  let!(:account) { create :account, profile: profile }

  before { login_as(account, scope: :account) }

  specify do
    visit profile_builder_path(resources: :issues)
    expect(page).to have_css '.ruckus-modal .issues'

    visit profile_builder_path(resources: :events)
    expect(page).to have_css '.ruckus-modal .events'

    visit profile_builder_path(resources: :press)
    expect(page).to have_css '.ruckus-modal .press-releases'

    visit profile_builder_path(resources: :media)
    expect(page).to have_css '.ruckus-modal .photo-stream'

    visit profile_builder_path(resources: :info)
    expect(page).to have_css '.ruckus-modal .general-info'

    visit profile_builder_path(resources: :biography)
    expect(page).to have_css '.ruckus-modal .biography'

    visit profile_builder_path(resources: :photo)
    expect(page).to have_css '.ruckus-modal .edit-photo'

    visit profile_builder_path(resources: :featured)
    expect(page).to have_css '.ruckus-modal .edit-featured'

    visit profile_builder_path(resources: :background)
    expect(page).to have_css '.ruckus-modal .edit-background'

    visit profile_builder_path(resources: :stream)
    expect(page).to have_css '.ruckus-modal .photo-stream'
  end
end
