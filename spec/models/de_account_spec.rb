require 'rails_helper'

describe DeAccount do
  describe 'validations' do
    it { expect(subject).to belong_to(:profile) }
    it { expect(subject).to belong_to(:credit_card) }
    it { expect(subject).to validate_acceptance_of(:terms) }
    it { expect(subject).to validate_confirmation_of(:password) }
    it { expect(subject).to validate_confirmation_of(:bank_account_number) }
    it { expect(subject).to validate_inclusion_of(:account_state).in_array(US_STATES_ABBREVIATIONS) }
    it { expect(subject).to validate_presence_of(:email) }
    it { expect(subject).to validate_presence_of(:password) }
    it { expect(subject).to validate_presence_of(:account_full_name) }
    it { expect(subject).to validate_presence_of(:account_committee_name) }
    it { expect(subject).to validate_presence_of(:account_committee_id) }
    it { expect(subject).to validate_presence_of(:account_address) }
    it { expect(subject).to validate_presence_of(:account_city) }
    it { expect(subject).to validate_presence_of(:account_state) }
    it { expect(subject).to validate_presence_of(:account_zip) }
    it { expect(subject).to validate_presence_of(:account_recipient_kind) }
    it { expect(subject).to validate_presence_of(:account_campaign_disclaimer) }
    it { expect(subject).to validate_presence_of(:bank_account_name) }
    it { expect(subject).to validate_presence_of(:bank_routing_number) }
    it { expect(subject).to validate_presence_of(:bank_account_number) }

    it 'should validate contribution_limit' do
      expect(subject).to allow_value(1).for(:contribution_limit)
      expect(subject).to allow_value(nil).for(:contribution_limit)
      expect(subject).to allow_value(100000).for(:contribution_limit)
      expect(subject).not_to allow_value(1.23).for(:contribution_limit)
      expect(subject).not_to allow_value(0).for(:contribution_limit)
      expect(subject).not_to allow_value(-1).for(:contribution_limit)
      expect(subject).not_to allow_value(100001).for(:contribution_limit)
    end
  end

  describe 'methods' do
    let!(:profile) { create(:candidate_profile) }

    describe '#values_for_donation_modal' do
      let(:de_account1) { build(:de_account, profile: profile, contribution_limit: 2500) }
      let(:de_account2) { build(:de_account, profile: profile, contribution_limit: 1000) }
      let(:de_account3) { build(:de_account, profile: profile, contribution_limit: 2600) }
      let(:de_account4) { build(:de_account, profile: profile, contribution_limit: 500) }
      let(:de_account5) { build(:de_account, profile: profile, contribution_limit: 100) }
      let(:de_account6) { build(:de_account, profile: profile, contribution_limit: 93) }
      let(:de_account7) { build(:de_account, profile: profile, contribution_limit: 35) }
      let(:de_account8) { build(:de_account, profile: profile, contribution_limit: 12) }
      let(:de_account9) { build(:de_account, profile: profile, contribution_limit: 7) }
      let(:de_account10) { build(:de_account, profile: profile, contribution_limit: 10000) }

      it 'should display proper values' do
        expect(de_account10.values_for_donation_modal).to eq [50, 250, 500, 1250, 2500, 3750, 5000]
        expect(de_account1.values_for_donation_modal).to eq [10, 25, 50, 100, 500, 1_000, 2_500]
        expect(de_account2.values_for_donation_modal).to eq [10, 50, 100, 250, 500, 750, 1000]
        expect(de_account3.values_for_donation_modal).to eq [26, 130, 260, 650, 1300, 1950, 2600]
        expect(de_account4.values_for_donation_modal).to eq [5, 25, 50, 125, 250, 375, 500]
        expect(de_account5.values_for_donation_modal).to eq [1, 5, 10, 25, 50, 75, 100]
        expect(de_account6.values_for_donation_modal).to eq [1, 5, 9, 23, 47, 70, 93]
        expect(de_account7.values_for_donation_modal).to eq [1, 2, 4, 9, 18, 26, 35]
        expect(de_account8.values_for_donation_modal).to eq [1, 3, 6, 9, 12] # test for removing duplicates
        expect(de_account9.values_for_donation_modal).to eq [1, 2, 4, 5, 7] # test for many small values
      end
    end

    describe '#attributes_for_de' do
      let(:de_account) { build(:de_account, profile: profile, contribution_limit: 199) }

      specify do
        result = de_account.attributes.merge(password: de_account.password).with_indifferent_access
        result[:contribution_limit] = 200

        expect(de_account.send(:attributes_for_de)).to eq result
      end
    end

    describe '#create_de_account' do
      let(:de_account) { build(:de_account, profile: profile) }

      it 'should go through entire process of activation' do
        Sidekiq::Testing.inline! do
          allow(DEApi).to receive(:show_recipient).and_return('status' => 'active')
          de_account.save!
          expect(de_account.reload.is_active_on_de).to be_truthy
        end
      end

      it 'should schedule account status check' do
        expect { de_account.save! }.to change(DeAccountStatusChecker.jobs, :size).by(1)
      end
    end
  end
end

describe 'Credit Card params' do
  let!(:de_account)  do
    create :de_account, account_full_name: 'John Smith',
                                     account_committee_id: 'FEC 123',
                                     account_recipient_kind: 'federal_account',
                                     contact_phone: '123-432-1234',
                                     contact_address: 'address 123',
                                     contact_city: 'Denver',
                                     contact_state: 'CO',
                                     contact_zip: '12345',
                                     bank_account_name: 'bankick',
                                     bank_routing_number: 'routing',
                                     bank_account_number: '87654321',
                                     bank_account_number_confirmation: '87654321',
                                     email: 'johnsmith@gmail.com',
                                     password: 'secret123',
                                     password_confirmation: 'secret123',
                                     account_party: 'Party!',
                                     account_state: 'NY',
                                     account_district_or_locality: '10th district',
                                     credit_card_attributes: { number: '4111111111111111',
                                                               cvv: '123',
                                                               month: '02',
                                                               year: '2019' }
  end

  it 'should save credit card' do
    de_account.credit_card.tap do |cc|
      expect(cc.number).to eq '4111111111111111'
      expect(cc.cvv).to eq '123'
      expect(cc.month).to eq '02'
      expect(cc.year).to eq '2019'
    end
  end

  it 'should format correct data for DE' do
    # Note! Credit Card fields are not submitted to DE!
    de_account.send(:attributes_for_de).tap do |attributes|
      expect(attributes[:account_full_name]).to eq 'John Smith'
      expect(attributes[:account_committee_id]).to eq 'FEC 123'
      expect(attributes[:account_recipient_kind]).to eq 'federal_account'
      expect(attributes[:contact_phone]).to eq '123-432-1234'
      expect(attributes[:contact_address]).to eq 'address 123'
      expect(attributes[:contact_city]).to eq 'Denver'
      expect(attributes[:contact_state]).to eq 'CO'
      expect(attributes[:contact_zip]).to eq '12345'
      expect(attributes[:bank_account_name]).to eq 'bankick'
      expect(attributes[:bank_routing_number]).to eq 'routing'
      expect(attributes[:bank_account_number]).to eq '87654321'
      expect(attributes[:email]).to eq 'johnsmith@gmail.com'
      expect(attributes[:password]).to eq 'secret123'
      expect(attributes[:account_party]).to eq 'Party!'
      expect(attributes[:account_state]).to eq 'NY'
      expect(attributes[:account_district_or_locality]).to eq '10th district'
    end
  end
end
