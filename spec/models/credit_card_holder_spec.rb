require 'rails_helper'

describe CreditCardHolder do
  describe 'associations' do
    specify { expect(subject).to belong_to :credit_card }
    specify { expect(subject).to belong_to :profile }
    specify { expect(subject).to belong_to :coupon }
  end

  describe 'validations' do
    let(:profile) { create :candidate_profile }
    subject { build :credit_card_holder, profile: profile }

    specify do
      expect(subject).to validate_presence_of(:city)
      expect(subject).to validate_presence_of(:address)
      expect(subject).to validate_presence_of(:zip)
      expect(subject).to validate_presence_of(:state)
      expect_to_validate_zip_format(:zip)
      expect(subject).to validate_inclusion_of(:state).in_array(US_STATES_ABBREVIATIONS)
      expect(subject).to ensure_length_of(:first_name).is_at_least(2).is_at_most(25)
      expect(subject).to ensure_length_of(:last_name).is_at_least(2).is_at_most(25)
      expect_to_validate_format_field(:first_name)
      expect_to_validate_format_field(:last_name)
    end

    specify { expect(subject).to accept_nested_attributes_for(:credit_card) }

    context 'coupon_code' do
      subject { build(:credit_card_holder, profile: profile, coupon_code: coupon_code) }

      context 'without coupon code' do
        let(:coupon_code) { nil }
        specify { expect(subject).to be_valid }
      end

      context 'with nonexistent code' do
        let(:coupon_code) { 'some-code' }

        specify do
          expect(subject).not_to be_valid
          expect(subject.errors[:coupon_code]).to eq ['invalid code']
        end
      end

      context 'with expired code' do
        let!(:coupon) { create(:coupon, code: 'e', expired_at: Time.now - 2.days) }
        let(:coupon_code) { 'e' }

        specify do
          expect(subject).not_to be_valid
          expect(subject.errors[:coupon_code]).to eq ['invalid code']
        end
      end

      context 'used code' do
        let!(:coupon) { create(:coupon, code: 'd') }
        let!(:card_holder) { create :credit_card_holder, coupon: coupon }
        let(:coupon_code) { 'd' }

        specify { expect(subject).to be_valid }
      end

      context 'with valid code' do
        let!(:coupon) { create(:coupon, code: 'd') }
        let(:coupon_code) { 'd' }

        specify do
          expect(subject).to be_valid
          expect(subject.coupon).to eq coupon
        end
      end
    end
  end

  describe '#real?' do
    context 'invalid' do
      subject { build(:credit_card_holder, city: nil, profile: profile) }

      context 'without accounts' do
        let(:profile) { create(:profile, accounts: [], account: nil) }
        specify('without accounts') { expect(subject).to_not be_real }
      end

      context 'with accounts' do
        let(:profile) { create(:profile) }
        specify('without accounts') { expect(subject).to_not be_real }
      end
    end

    context 'valid' do
      subject { build(:credit_card_holder, profile: profile) }

      context 'without accounts' do
        let(:profile) { create(:profile, accounts: [], account: nil) }
        specify('without accounts') { expect(subject).to_not be_real }
      end

      context 'with accounts' do
        let!(:ownership) { create :ownership, account: account, profile: profile }
        let(:account)    { create :account, profile: profile }
        let(:profile)    { create :profile }
        specify('without accounts') { expect(subject).to be_real }
      end
    end
  end
end
