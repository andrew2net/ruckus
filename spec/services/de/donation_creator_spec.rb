require 'rails_helper'

describe De::DonationCreator do
  let!(:profile) { create(:candidate_profile, credit_card_holder: nil) }
  let!(:account) { profile.account }
  let!(:de_account) { create(:de_account, profile: profile) }
  let!(:unprocessed_donation) do
    # keep strings in hash to test indifferent access
    attributes_for(:donation, amount: 10).merge('cc_number' => '4111111111111111',
                                                'cc_cvv'    => '421',
                                                cc_month:   12,
                                                cc_year:    2016,
                                                profile_id: profile.id,
                                                fee_tier:   3)
  end
  let!(:new_donation) { De::DonationCreator.new }
  let!(:formatted_data) { new_donation.format_data(unprocessed_donation) }

  describe '#initialize' do
    it 'should set variables correctly' do
      formatted_data.tap do |data|
        expect(data[:donor_first_name]).to eq unprocessed_donation[:donor_first_name]
        expect(data[:donor_last_name]).to eq unprocessed_donation[:donor_last_name]
        expect(data[:donor_address1]).to eq unprocessed_donation[:donor_address_1]
        expect(data[:donor_address2]).to eq unprocessed_donation[:donor_address_2]
        expect(data[:donor_city]).to eq unprocessed_donation[:donor_city]
        expect(data[:donor_state]).to eq unprocessed_donation[:donor_state]
        expect(data[:donor_zip]).to eq unprocessed_donation[:donor_zip]
        expect(data[:donor_email]).to eq unprocessed_donation[:donor_email]
        expect(data[:donor_phone]).to eq unprocessed_donation[:donor_phone]
        expect(data[:cc_number]).to eq '4111111111111111'
        expect(data[:cc_verification_value]).to eq '421'
        expect(data[:cc_month]).to eq 12
        expect(data[:cc_year]).to eq 2016
        expect(data[:fee_tier]).to eq 3
        expect(data[:cc_first_name]).to eq unprocessed_donation[:donor_first_name]
        expect(data[:cc_last_name]).to eq unprocessed_donation[:donor_last_name]
        expect(data[:cc_zip]).to eq unprocessed_donation[:donor_zip]
        expect(data[:compliance_employer]).to eq unprocessed_donation[:employer_name]
        expect(data[:compliance_occupation]).to eq unprocessed_donation[:employer_occupation]
        expect(data[:compliance_employer_address]).to eq unprocessed_donation[:employer_address]
        expect(data[:compliance_employer_city]).to eq unprocessed_donation[:employer_city]
        expect(data[:compliance_employer_state]).to eq unprocessed_donation[:employer_state]
        expect(data[:compliance_employer_zip]).to eq unprocessed_donation[:employer_zip]
        expect(data[:line_items].first[:amount]).to eq "$#{unprocessed_donation[:amount]}"
        expect(data[:line_items].first[:recipient_id]).to eq de_account.reload.uuid
      end
    end
  end

  describe '#process', :unstub_de, cassette_name: :democracy_engine_create_donation do
    it 'should process donation' do
      expect(DEApi).to receive(:create_donation).with(formatted_data)
      new_donation.process(unprocessed_donation)
    end
  end
end
