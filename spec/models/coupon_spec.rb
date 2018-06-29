require 'rails_helper'

describe Coupon do
  subject { build(:coupon) }

  specify 'associations' do
    expect(subject).to have_one :credit_card_holder
  end

  describe 'validations' do
    specify do
      expect(subject).to validate_presence_of(:code)
    end

    specify 'code format' do
      expect(subject).to allow_value('dsadsa', 'dsa232dsa', '3213213').for(:code)
      expect(subject).not_to allow_value('dsa*dsa', '32 ds', 'dasds-dsa').for(:code)
    end
  end

  describe 'datetime monkey patch' do
    subject { build(:coupon) }

    specify do
      expect { subject.expired_at = '10/20/2016' }.to_not raise_error
      expect(subject.expired_at).to be_nil
    end
  end

  describe 'methods' do
    describe '::by_code' do
      let!(:coupon1) { create(:coupon, code: 'code1') }
      let!(:coupon2) { create(:coupon, code: 'code2') }

      specify { expect(described_class.by_code('code1')).to eq [coupon1] }
    end

    describe '::not_expired' do
      let!(:coupon1) { create(:coupon, expired_at: 1.day.from_now) }
      let!(:coupon2) { create(:coupon, expired_at: 1.day.ago) }
      let!(:coupon3) { create(:coupon, expired_at: nil) }

      specify do
        described_class.not_expired.to_a.tap do |coupons|
          expect(coupons).to include coupon1, coupon3
          expect(coupons).to_not include coupon2
        end
      end
    end

    describe '::not_applied' do
      let!(:coupon1) { create(:coupon) }
      let!(:coupon2) { create(:coupon) }
      let!(:credit_card_holder) { create(:credit_card_holder, coupon: coupon1) }

      specify { expect(described_class.not_applied).to eq [coupon2] }
    end

    describe 'expired?' do
      let!(:coupon) { build(:coupon, expired_at: expired_at) }

      context 'not expired' do
        let(:expired_at) { Time.now + 2.days }
        specify { expect(coupon).not_to be_expired }
      end

      context 'expired' do
        let(:expired_at) { Time.now - 2.days }
        specify { expect(coupon).to be_expired }
      end

      context 'when expired_at nil' do
        let(:expired_at) { nil }
        specify { expect(coupon).not_to be_expired }
      end
    end
  end
end
