require 'rails_helper'

describe User do
  describe 'associations' do
    it { expect(subject).to have_many(:questions).dependent(:destroy) }
    it { expect(subject).to have_many(:subscriptions) }
    it { expect(subject).to have_many(:profiles).through(:subscriptions) }
  end

  describe 'validations' do
    it { expect(subject).to validate_uniqueness_of(:email) }
    it { expect(subject).to validate_presence_of(:email) }
    it { expect(subject).to allow_value('email@addresse.foo').for(:email) }
    it { expect(subject).not_to allow_value('foo').for(:email) }
    it { expect(subject).not_to allow_value('%$#$^%$&^#@gmail.com').for(:email) }
  end

  describe 'scopes' do
    let!(:good_subscriber) { create :user, subscribed: true, email: 'good@gmail.com' }
    let!(:bad_subscriber) { create :user, subscribed: false, email: 'bad@gmail.com' }

    describe '::search' do
      it 'should search subscribers' do
        expect(User.search('good@gmail.com')).to eq [good_subscriber]
        expect(User.search('oo')).to eq [good_subscriber]
        expect(User.search('Oo')).to eq [good_subscriber]
      end
    end

    describe '::to_csv' do
      it 'should convert into csv' do
        expect(User.to_csv).to eq [
          good_subscriber.attributes.keys.join(','),
          good_subscriber.attributes.values.join(','),
          bad_subscriber.attributes.values.join(',')
        ].compact.join("\n") + "\n"
      end
    end
  end

  describe 'class methods' do
    describe 'subscribe' do
      let!(:profile) { create(:candidate_profile) }

      it 'should subscribe new user' do
        User.subscribe 'test@example.com', profile

        User.first.tap do |user|
          expect(user.email).to eq 'test@example.com'
          expect(user).to be_subscribed
        end
      end

      it 'should not subscribe existing user' do
        profile.users.create email: 'test@example.com', subscribed: true

        user = User.subscribe 'test@example.com', profile

        expect(user.errors[:email]).to include 'You are already subscribed'
      end

      it 'should resubscribe' do
        profile.users.create email: 'test@example.com', subscribed: false

        user = User.subscribe 'test@example.com', profile

        expect(user.errors[:email]).to include 'You are already subscribed'
        expect(user.reload).to be_subscribed
      end
    end
  end

  describe '#name' do
    let!(:user) { build :user, first_name: 'John', last_name: 'Smith' }

    it 'should join first and last name' do
      expect(user.name).to eq 'John Smith'
    end
  end
end
