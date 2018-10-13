require 'rails_helper'

describe AccountMailer do
  let(:profile)             { create(:candidate_profile) }
  let!(:account)            { create :account, profile: profile }
  let!(:de_account)         { create(:de_account, profile: profile) }
  let!(:credit_card_holder) { create :credit_card_holder, profile: profile }
  let!(:card)               { credit_card_holder.credit_card }
  let!(:donation) do
    create(:donation, profile: profile, amount: '50', donor_first_name: 'Bob', donor_last_name: 'Marley')
  end
  let!(:support_message) do
    create :support_message, name: 'Bob', email: 'bob@gmail.com', subject: 'Test Subject', message: 'Test Message'
  end

  let!(:user)     { create :user, email: 'user@test.com' }
  let!(:question) { create :question, profile: profile, user: user }

  specify '#question_message' do
    mail = AccountMailer.question_message(question.id)

    expect(mail.to.first).to eq account.email
    expect(mail.subject).to eq 'Question'
    expect(mail.from.first).to eq 'user@test.com'
  end

  specify '#question_asker_notification' do
    mail = AccountMailer.question_asker_notification(question.id)

    expect(mail.to.first).to eq 'user@test.com'
    expect(mail.subject).to eq 'Question Successfully Submitted'
    expect(mail.from.first).to eq 'info@example.com'
  end

  describe 'welcome_email' do
    let(:mail) { AccountMailer.welcome_email(account.id) }

    after do
      expect(mail.to.first).to eq account.email
      expect(mail.subject).to eq 'Your Powerful New Website is Ready!'
      expect(mail.from.first).to eq 'info@example.com'
      expect(mail.body).to have_link 'Twitter'
      expect(mail.body).to have_link 'Facebook'
    end

    context 'account without domain' do
      let(:account) { create :account }
      let(:profile) { create :candidate_profile, :without_domain, account: account }
      specify('canidate without domain') {}
    end
  end

  specify 'donation_notification' do
    mail = AccountMailer.donation_notification(account.id, donation.id)

    expect(mail.to.first).to eq account.email
    expect(mail.subject).to eq 'New Donation Received!'
    expect(mail.from.first).to eq 'info@example.com'

    expect(mail.body.raw_source).to match /.*50.*/
    expect(mail.body.raw_source).to match /.*Bob Marley.*/
    expect(mail.body).to have_link 'recipient'
  end

  describe '#donor_donation_notification' do
    let(:mail) { described_class.donor_donation_notification(donation.id) }

    specify do
      expect(mail.to.first).to eq donation.donor_email
      expect(mail.subject).to eq 'Your donation is processing'
      expect(mail.from.first).to eq 'info@example.com'

      expect(mail.body.raw_source).to match /.*50.*/
      expect(mail.body.raw_source).to match /.*Bob Marley.*/
    end
  end

  specify '#support_message' do
    AccountMailer.support_message(support_message.id) do |mail|
      expect(mail).to be_present
      expect(mail.subject).to         eq 'Test Subject'
      expect(mail.to).to              eq 'contact@localhost:3000'
      expect(mail.from.first).to      eq 'bob@gmail.com'
      expect(mail.body.raw_source).to eq "Test Message\n" # keep double quotes
    end
  end
end
