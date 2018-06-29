require 'rails_helper'

describe 'Help' do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { login_as(account, scope: :account) }

  let(:builder_overlay_path) { profile_help_path }
  it_behaves_like 'Builder overlay'

  specify 'link should be present' do
    visit profile_root_path
    expect(page).to have_link nil, profile_help_path
  end

  specify 'help links' do
     visit profile_help_path
     expect(page).to have_link 'reach out to us', front_contact_us_path
     expect(page).to have_link 'HELP section', profile_help_path
  end

  describe 'FAQ content' do
    before { create :page, name: 'faq', data: 'some <b>text</b>' }

    it 'should display faq content' do
      visit profile_help_path

      expect(page.html).to include 'some <b>text</b>'
    end
  end
end
