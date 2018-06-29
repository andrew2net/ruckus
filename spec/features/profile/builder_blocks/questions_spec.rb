require 'rails_helper'

describe 'Questions' do
  let(:profile) { create :candidate_profile, questions_on: questions_on }
  let(:account) { create :account, profile: profile }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
  end

  describe 'enable questions' do
    let(:questions_on) { true }

    specify do
      expect(page).to have_css 'a', text: /Ask me a Question!/
      expect(page).not_to have_css "a[disabled='disabled']", text: /Ask me a Question!/
    end
  end

  describe 'disable questions' do
    let(:questions_on) { false }
    specify { expect(page).to have_css "a[disabled='disabled']", text: /Ask me a Question!/ }
  end
end
