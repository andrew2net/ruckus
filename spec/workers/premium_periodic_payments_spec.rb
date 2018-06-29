require 'rails_helper'

RSpec.describe PremiumPeriodicPayments do
  context 'success' do
    let!(:profile) { create :candidate_profile }
    let!(:card_holder) { create :credit_card_holder, last_payment: Time.current - 2.month, profile: profile }
    let!(:account)           { create :account, profile: profile }
    let!(:ownership) { create :ownership, account: account, profile: profile }

    before do
      described_class.new.perform
    end

    it 'should activate an account when it is ready' do
      expect(card_holder.reload.last_payment.to_date).to eq Date.current
    end
  end

  context 'check last_payment condition' do
    let!(:profile) { create :candidate_profile }
    let!(:card_holder) { create :credit_card_holder, last_payment: Time.current - 2.month, profile: profile }
    let!(:account)           { create :account, profile: profile }
    let!(:ownership) { create :ownership, account: account, profile: profile }

    it do
      expect_any_instance_of(CreditCardHolder).to receive(:update)
      described_class.new.perform
      expect_any_instance_of(CreditCardHolder).to_not receive(:update)
      described_class.new.perform
    end
  end
end
