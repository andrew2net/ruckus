require 'rails_helper'

describe Front::DonationsController do
  let(:profile)      { create(:candidate_profile, donation_notifications_on: donation_notifications_on, donations_on: donations_on) }
  let(:account)      { create :account, profile: profile }
  let(:landing_page) { profile_path(account.profile) }
  let!(:de_account)  { create :de_account, profile: profile }
  let(:donation_notifications_on) { true }
  let(:donations_on) { true }

  specify 'GET #new' do
    expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:visitor_donate_cta)
    get :new, profile_id: profile.id
    expect(response).to render_template 'new'
    expect(response).not_to render_template 'layouts/application'
  end

  describe 'POST #create' do
    let!(:donation_attributes) { attributes_for(:donation, credit_card_attributes: attributes_for(:credit_card)) }

    context 'should send notifications' do

      describe 'success' do
        let(:donation_notifications_on) { true }

        specify do
          expect{xhr :post, :create, profile_id: account.profile.id, donation: donation_attributes}
          .to change{ActionMailer::Base.deliveries.count}.by 2
        end

        specify do
          expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:visitor_donate_success,
                                                                                donor_email: 'johnsmith@gmail.com',
                                                                                donor_name: 'John Smit',
                                                                                donation_amount: 10,
                                                                                donation_date: Date.today)
          xhr :post, :create, profile_id: profile.id, donation: donation_attributes

          expect(profile.donations.count).to eq 1
          expect(response).to render_template 'create'

        end
      end

      describe 'failure' do
        let(:donations_on) { false }

        specify do
          expect {
            xhr :post, :create, profile_id: profile.id, donation: donation_attributes
          }.to change(Donation, :count).by(0)

          expect(response.status).to eq 422
        end
      end
    end

    context 'should NOT send notifications' do
      let(:donation_notifications_on) { false }

      specify 'success' do
        xhr :post, :create, profile_id: profile.id, donation: donation_attributes

        expect(profile.donations.count).to eq 1
        expect(response).to render_template 'create'

        expect(ActionMailer::Base.deliveries).not_to be_any
      end
    end

    it 'error' do
      xhr :post, :create, profile_id: profile.id, donation: donation_attributes.merge(donor_email: nil)

      expect(profile.donations.count).to eq 0
      expect(response).to render_template 'create'

      expect(ActionMailer::Base.deliveries).not_to be_any
    end
  end
end
