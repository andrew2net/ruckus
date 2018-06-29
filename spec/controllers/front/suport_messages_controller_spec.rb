require 'rails_helper'

describe Front::SupportMessagesController do

  describe 'POST #create' do
    specify 'success' do
      xhr :post, :create, support_message: { name: 'Bob',
                                             email: 'bob@gmail.com',
                                             subject: 'Message Subject 1',
                                             message: 'Test Message' }

      SupportMessage.first.tap do |support_message|
        expect(support_message).to         be_present
        expect(support_message.subject).to eq 'Message Subject 1'
        expect(support_message.email).to   eq 'bob@gmail.com'
        expect(support_message.name).to    eq 'Bob'
        expect(support_message.message).to eq 'Test Message'
      end
    end
  end
end
