require 'rails_helper'

describe Account::RegistrationsController do
  describe 'GET #new' do
    specify do
      get :new
      expect(response).to render_template :new
      expect(assigns(:account)).to be_a Account
    end
  end

  describe 'POST #create' do
    let!(:medium) { create :medium, image: File.open(Rails.root.join('spec', 'fixtures', 'backgrounds', 'Farm_2.jpg')) }
    let(:valid_params) do
      {
        email: 'newcandidate@test.com',
        password: 'password123',
        password_confirmation: 'password123',
        candidate_profile_attributes: {
          first_name: 'John',
          last_name: 'Smith',
          office: 'President'
        }
      }

    end

    before { expect_any_instance_of(described_class).to receive(:render).at_least(:once) }

    specify 'success' do
      expect(AccountMailer).to receive_message_chain(:welcome_email, :deliver)
      expect {
        post :create, account: valid_params
      }.to change(Account, :count).by 1

      Account.last.tap do |account|
        expect(account.invitation_created_at).to be_present
        expect(account.invitation_accepted_at).to be_present
        expect(account.invitation_sent_at).to be_present

        account.candidate_profile.tap do |profile|
          expect(profile.first_name).to eq 'John'
          expect(profile.last_name).to eq 'Smith'
          expect(profile.background_image_medium).to eq medium
        end
      end
    end

    specify 'failure' do
      expect(AccountMailer).not_to receive(:welcome_email)
      expect {
        post :create, account: valid_params.merge(email: '')
      }.to change(Account, :count).by 0
    end
  end

  describe 'PATCH #update' do
    let!(:account) { create :account, password: '12345678', password_confirmation: '12345678' }
    let!(:profile) { create :candidate_profile, first_name: 'Bob', last_name: 'Johnsom', phone: '123-543-3211', account: account }
    let!(:valid_params) do
      {
        email: 'new_email@gmail.com',
        profile_attributes: {
          phone: '123-123-1234'
        }
      }
    end

    before { sign_in(account) }

    specify 'success' do
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:display_phone_update)

      patch :update, account: valid_params

      expect(account.reload.email).to eq 'new_email@gmail.com'
      expect(profile.reload.phone).to eq '123-123-1234'

      expect(response).to redirect_to root_path
    end

    specify 'failure' do
      patch :update, account: valid_params.merge(profile_attributes: { first_name: '' })
      expect(response).to redirect_to edit_profile_my_account_path
    end
  end

  describe 'DELETE #destroy' do
    let(:account) { create :account, deleted_at: nil }

    before { sign_in(account) }

    specify do
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:account_status_deactivate)

      delete :destroy, id: account.id
      expect(account.reload.deleted_at).to be_present
    end
  end
end
