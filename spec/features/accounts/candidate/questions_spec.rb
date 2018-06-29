require 'rails_helper'

describe "Account's page / Questions" do
  include ActionView::Helpers::DateHelper

  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:photo)     { File.open(Rails.root.join('spec', 'fixtures', 'photo.jpg')) }
  let!(:profile)   { create :candidate_profile, photo: photo, questions_on: true, premium_by_default: true }
  let!(:question1) { create :question, profile: profile, text: 'question 1' }
  let!(:question2) { create :question, profile: profile, text: 'question 2' }

  before do
    question2.update(created_at: Time.now + 1.day)
    visit with_subdomain(profile.domain.name)
  end

  describe 'create question' do
    it 'should hide when off' do
      expect(page).to have_content('Ask me a Question!')
      account.profile.update(questions_on: false)
      visit current_url
      expect(page).not_to have_content('Ask me a Question!')
    end

    it 'should have image button' do
      expect(page).to have_selector("a.btn-speech-bubble img[src='#{profile.photo_url(:small_thumb)}']")
    end

    specify 'failure', :js do
      find('a.btn-speech-bubble').click

      within '.mfp-content' do
        click_on 'Submit'
      end

      find('.mfp-close').click
      expect(page).not_to have_selector('.mfp-content')
    end

    specify 'success', :js do
      find('a.btn-speech-bubble').click

      user_attrs = attributes_for(:user)
      question_attrs = attributes_for(:question)

      within '.mfp-content' do
        fill_in 'question_user_attributes_first_name', with: user_attrs[:first_name]
        fill_in 'question_user_attributes_last_name', with: user_attrs[:last_name]
        fill_in 'question_user_attributes_email', with: user_attrs[:email]
        check 'question_user_attributes_subscribed'
        fill_in 'question_text', with: question_attrs[:text]
        click_on 'Submit'
      end

      expect(page).not_to have_selector('.mfp-content')
    end
  end
end
