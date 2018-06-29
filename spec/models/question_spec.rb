require 'rails_helper'

describe Question do
  describe 'associations' do
    it { expect(subject).to belong_to(:user) }
    it { expect(subject).to belong_to(:profile) }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:text) }
  end

  it 'should have nested attributes' do
    expect(subject).to accept_nested_attributes_for :user
  end

  describe 'scopes' do
    specify '::by_created_at' do
      profile = create(:candidate_profile)
      question1 = create(:question, profile: profile)
      question2 = create(:question, profile: profile, created_at: Time.now - 1.day)
      question3 = create(:question, profile: profile, created_at: Time.now + 1.day)

      expect(Question.by_created_at).to eq [question3, question1, question2]
    end
  end

  describe '#add_user' do
    let!(:profile) { create(:candidate_profile) }
    let(:question) { build(:question, user: nil, profile: profile) }
    let(:params) { { email: 'user@example.com', first_name: 'Carl', last_name: 'Johnson' } }

    after do
      expect(question).to be_persisted

      question.user.tap do |user|
        expect(user).to be_persisted
        expect(user.email).to      eq 'user@example.com'
        expect(user.first_name).to eq 'Carl'
        expect(user.last_name).to  eq 'Johnson'
        expect(user.profiles).to eq [question.profile]
      end
    end

    specify 'with new user' do
      question.add_user(params)
    end

    describe 'with existing user without current profile' do
      let!(:user) { create(:user, params) }

      specify do
        question.add_user(params)
        expect(question.user).to eq user
      end
    end

    describe 'with existing user with current profile' do
      let!(:subscription) { create(:subscription, user: create(:user, params)) }
      let!(:profile) { subscription.profile }
      let!(:user) { subscription.user }

      specify do
        question.add_user(params)
        expect(question.user).to eq user
      end
    end
  end
end
