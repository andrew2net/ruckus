require 'rails_helper'

describe SupportMessage do
  it 'should have validations' do
    expect(subject).to validate_presence_of(:message)
    expect(subject).to validate_presence_of(:name)
    expect(subject).to validate_presence_of(:email)
    expect(subject).to validate_presence_of(:subject)
    expect_to_validate_email(:email)
  end

  describe '#deliver_message' do
    it 'should deliver a mail after creating the record' do
      create :support_message, name: 'Bob Smith',
                               email: 'bob@gmail.com',
                               subject: 'Message Subject 1',
                               message: 'Test Message'

      ActionMailer::Base.deliveries.last.tap do |mail|
        expect(mail).to be_present
        expect(mail.subject).to         eq 'Message Subject 1'
        expect(mail.to.first).to        eq 'contact@example.com'
        expect(mail.from.first).to      eq 'bob@gmail.com'
        expect(mail.body.raw_source).to eq "Test Message\n" # keep double quotes
      end
    end
  end
end
