require 'rails_helper'

describe "Accounts/candidate/press link bug" do
  let!(:profile)   { create :candidate_profile, events_on: true, press_on: false }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:event)     { create :event, profile: profile }

  before { visit with_subdomain(profile.domain.name) }

  specify 'should be no link' do
    expect(page).to have_no_content 'Add New Press Link'
  end
end
