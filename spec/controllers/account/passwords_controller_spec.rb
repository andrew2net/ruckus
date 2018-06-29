require 'rails_helper'

describe Account::PasswordsController do
  describe 'POST create' do
    let(:account) { create(:account) }

    specify 'success' do
      xhr :post, :create, account: { email: account.email, password: account.password }

      expect(flash[:notice]).to eq 'Password Reset Instructions Successfully Sent'
      expect(response).to render_template 'create'

      ActionMailer::Base.deliveries.last.tap do |mail|
        expect(mail).to be_present
        expect(mail.to.first).to eq account.email
        expect(mail.body).to have_link('Change my password')
      end
    end

    describe 'success and failure' do
      specify 'first success then error' do
        xhr :post, :create, account: { email: account.email, password: account.password }
        xhr :post, :create, account: { email: 'unknown@gmail.com' }

        expect(flash[:notice]).to be_blank
        expect(flash[:alert]).to be_present
      end

      specify 'first error then success' do
        xhr :post, :create, account: { email: 'unknown@gmail.com' }
        xhr :post, :create, account: { email: account.email, password: account.password }

        expect(flash[:alert]).to be_blank
        expect(flash[:notice]).to be_present
      end
    end

    specify 'failure with no email' do
      xhr :post, :create, account: { email: nil }

      expect(flash[:alert]).to eq "Email can't be blank"
    end

    specify 'failure with wrong email' do
      xhr :post, :create, account: { email: 'wrong@gmail.com' }

      expect(flash[:alert]).to eq 'Email not found'
    end
  end
end
