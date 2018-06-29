require 'rails_helper'

describe CardExpiryNotifier do
  let!(:profile)     { create :candidate_profile }
  let!(:account)     { create :account, profile: profile }
  let!(:card_holder) { create :credit_card_holder, profile: profile }
  let!(:card)        { card_holder.credit_card }

  let(:worker) { CardExpiryNotifier.new }

  before do
    allow(CreditCard).to receive(:about_to_expire).and_return [card]
  end

  specify do
    expect(PremiumMailer).to receive(:card_expiry_notification).with(account, profile, card).and_call_original
    worker.perform

    ActionMailer::Base.deliveries.last.tap do |mail|
      expect(mail).to be_present
      expect(mail.subject).to eq 'Your credit card is about to expire!'
      expect(mail.to.first).to eq account.email
    end
  end
end

