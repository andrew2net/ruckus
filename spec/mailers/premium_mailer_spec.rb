require 'rails_helper'

describe PremiumMailer do
  let!(:profile) { create(:candidate_profile) }
  let!(:account) { create :account, profile: profile }
  let!(:credit_card_holder) { create :credit_card_holder, profile: profile }
  let!(:card) { credit_card_holder.credit_card }

  context '#profile_upgrading_notification' do
    subject { described_class.profile_upgrading_notification([account.email], profile, amount) }

    let(:amount) { '$10.0' }

    specify do
      expect(subject.to.first).to eq account.email
      expect(subject.subject).to eq 'Upgrading receipt'
      expect(subject.from.first).to eq 'info@example.com'
    end
  end

  specify '#discontinue_notification' do
    described_class.discontinue_notification(credit_card_holder) do |mail|
      expect(mail.to.first).to eq account.email
      expect(mail.subject).to eq 'Your site is no longer premium!'
      expect(mail.from.first).to eq 'info@ruck.us'
      expect(mail.body.raw_source).to match /.*#{card.last_four}.*/
    end
  end

  specify '#card_expiry_notification' do
    described_class.card_expiry_notification(account, profile, card) do |mail|
      expect(mail.to.first).to eq account.email
      expect(mail.subject).to eq 'Your credit card is about to expire!'
      expect(mail.from.first).to eq 'info@ruck.us'
      expect(mail.body.raw_source).to match /.*#{card.last_four}.*/
    end
  end
end
