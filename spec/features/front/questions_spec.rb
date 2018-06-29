require 'rails_helper'

describe 'Questions', :js do
  let!(:profile)   { create :candidate_profile, name: 'John Smith', questions_on: true, premium_by_default: true }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, account: account, profile: profile }

  before { visit with_subdomain(profile.domain.name) }

  it 'should have validation' do
    click_on 'Ask me a Question!'
    fill_in 'question_user_attributes_email', with: 'some-wrong-mail.com'
    click_on 'Submit'

    expect(page).to have_content('is invalid')
    expect(page).to have_content("can't be blank")
  end

  it 'should have proper text' do
    click_on 'Ask me a Question!'
    within '.ask-a-question-modal' do
      expect(page).to have_content 'Ask John Smith a Question'
      expect(page).to have_content 'Subscribe to email updates from John Smith'
    end
  end
end
