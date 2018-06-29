require 'rails_helper'

describe 'Settings' do
  let(:params) do
    {
      register_to_vote_on: true,
      donations_on:        true,
      press_on:            true,
      issues_on:           true,
      events_on:           true,
      biography_on:        true,
      media_on:            true,
      questions_on:        true,
      social_feed_on:      true
    }
  end

  let(:candidate_profile) { create(:candidate_profile, params) }
  let(:organization_profile) { create(:organization_profile, params) }
  let(:profile) { candidate_profile }
  let(:account) { create :account, profile: profile }
  let!(:de_account) { create(:de_account, profile: profile, is_active_on_de: true) }

  before do
    login_as(account, scope: :account)
    visit edit_profile_page_option_path
  end

  describe 'Edit' do
    it 'can edit information' do
      uncheck 'profile_register_to_vote_on'
      uncheck 'profile_donations_on'
      uncheck 'profile_press_on'
      uncheck 'profile_biography_on'
      uncheck 'profile_issues_on'
      uncheck 'profile_events_on'
      uncheck 'profile_media_on'
      uncheck 'profile_questions_on'
      click_on 'Update'

      account.profile.reload.tap do |profile|
        expect(profile.register_to_vote_on).to be_falsey
        expect(profile.donations_on).to        be_falsey
        expect(profile.press_on).to            be_falsey
        expect(profile.biography_on).to        be_falsey
        expect(profile.issues_on).to           be_falsey
        expect(profile.events_on).to           be_falsey
        expect(profile.media_on).to            be_falsey
        expect(profile.questions_on).to        be_falsey
      end
    end
  end

  describe 'content' do
    specify 'for Candidate' do
      within '#edit_profile' do
        expect(page).to have_content 'Biography'
        expect(page).to have_content 'Ask a Question'
        expect(page).to have_content 'Issues'
        expect(page).to have_content 'Media'
        expect(page).to have_content 'Press'
        expect(page).to have_content 'Events'
      end
    end

    context 'for Organization' do
      let(:profile) { organization_profile }

      specify do
        within '#edit_profile' do
          expect(page).to have_content 'Who We Are'
          expect(page).to have_content 'Ask a Question'
          expect(page).to have_content 'Priorities'
          expect(page).to have_content 'Media'
          expect(page).to have_content 'Press'
          expect(page).to have_content 'Events'
        end
      end
    end
  end
end
