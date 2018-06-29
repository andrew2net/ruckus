require 'rails_helper'

describe Donation do
  before do
    allow_any_instance_of(Profile).to receive(:de_account).and_return(DeAccount.new)
    allow_any_instance_of(De::DonationCreator).to(
      receive(:process).and_return(
        'cc_last_four' => '1234',
        'line_items'   => [{
          'transaction_guid' => '23456789',
          'transaction_url'  => 'http://www.trancaction.com'
        }]
      )
    )
    allow_any_instance_of(Donation).to receive(:credit_card).and_return(build :credit_card)
  end

  describe 'concerns' do
    it_behaves_like 'chartable'
  end

  describe 'associations' do
    it { expect(subject).to belong_to(:profile) }
    it { expect(subject).to belong_to(:credit_card) }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:donor_first_name) }
    it { expect(subject).to validate_presence_of(:donor_last_name) }
    it { expect(subject).to validate_presence_of(:donor_email) }
    it { expect(subject).to validate_presence_of(:donor_phone) }
    it { expect(subject).to validate_presence_of(:donor_address_1) }
    it { expect(subject).to validate_presence_of(:donor_city) }
    it { expect(subject).to validate_presence_of(:donor_state) }
    it { expect(subject).to validate_presence_of(:donor_zip) }
    it { expect(subject).to validate_presence_of(:amount) }

    it { expect(subject).to validate_acceptance_of(:agree_with_terms) }

    it { expect(subject).to validate_inclusion_of(:donor_state).in_array(US_STATES_ABBREVIATIONS) }
    it { expect(subject).to validate_inclusion_of(:employer_state).in_array(US_STATES_ABBREVIATIONS) }

    it { expect_to_validate_zip_format(:donor_zip) }
    it { expect_to_validate_zip_format(:employer_zip) }

    it { expect(subject).to allow_value(nil).for(:employer_state) }
    it { expect(subject).to allow_value(nil).for(:employer_zip) }

    it 'validates amount is allowed' do
      expect_to_validate_amount_inclusion(:amount)
    end
  end

  describe 'methods' do
    let!(:de_account)  { create(:de_account) }

    describe '#donor_name' do
      let!(:donation) { build :donation, donor_first_name: 'Bob', donor_last_name: 'Marley' }
      it 'should return full name' do
        expect(donation.donor_name).to eq 'Bob Marley'
      end
    end

    describe '#donor_full_address' do
      let!(:donation) do
        build :donation, donor_address_1: '343 Bob st.',
                         donor_city: 'City',
                         donor_zip: '12345',
                         donor_state: 'AZ'
      end

      it 'should return correctly formatted address' do
        expect(donation.donor_full_address).to eq '343 Bob st. City 12345 AZ'
      end
    end

    describe '#fee_tier' do
      let(:profile) { build(:candidate_profile, credit_card_holder: credit_card_holder) }
      let(:donation) { build(:donation, profile: profile) }

      context '1 point' do
        let(:credit_card_holder) { nil }
        specify { expect(donation.send(:fee_tier)).to eq 1 }
      end

      context '2 points' do
        let(:credit_card_holder) { build(:credit_card_holder, token: 'some-token') }
        specify { expect(donation.send(:fee_tier)).to eq 2 }
      end
    end
  end

end

describe 'DE errors', :unstub_de, cassette_name: :democracy_engine_invalid_donation do
  let!(:profile) { create(:candidate_profile, credit_card_holder: nil) }
  let!(:de_account)  { create(:de_account, profile: profile) }
  let!(:donation) { build(:donation, profile: profile) }

  before do
    allow_any_instance_of(De::DonationCreator)
      .to receive(:process).and_return([[:base, 'Card number invalid']])
  end

  it 'should not save record with DE errors if there are any' do
    donation.save
    expect(donation).to be_invalid
  end
end

describe 'donation cap' do
  context '2500' do
    let!(:de_account) { create(:de_account, contribution_limit: 2500) }
    specify { expect(de_account.donation_amounts).to eq (0.1..2500) }
  end

  context '1000' do
    let!(:de_account) { create(:de_account, contribution_limit: 1000) }
    specify { expect(de_account.donation_amounts).to eq (0.1..1000) }
  end

  context 'nil' do
    let!(:de_account) { create(:de_account, contribution_limit: nil) }
    specify { expect(de_account.donation_amounts).to eq(0.1..100_000) }
  end
end

describe 'Credit Card params' do
  let!(:profile) { create(:candidate_profile) }
  let!(:de_account) { create(:de_account, profile: profile) }
  let!(:donation) do
    create :donation, profile: profile,
                      donor_first_name: 'John',
                      donor_last_name: 'Smith',
                      donor_address_1: 'the Street 1',
                      donor_address_2: 'the Street 2',
                      donor_city: 'Denver',
                      donor_state: 'CO',
                      donor_zip: '12345',
                      donor_email: 'johnsmith@gmail.com',
                      donor_phone: '123-345-6789',
                      employer_name: 'Some Company',
                      employer_occupation: 'Manager',
                      employer_address: 'the Emp Street',
                      employer_city: 'New York City',
                      employer_state: 'NY',
                      employer_zip: '54321',
                      credit_card_attributes: { number: '4111111111111111',
                                                cvv: '123',
                                                month: '02',
                                                year: '2019' }
  end

  it 'should save credit card' do
    donation.credit_card.tap do |cc|
      expect(cc.number).to eq '4111111111111111'
      expect(cc.cvv).to eq '123'
      expect(cc.month).to eq '02'
      expect(cc.year).to eq '2019'
    end
  end

  it 'should give correct attributes for DE' do
    donation.send(:attributes_for_de).tap do |attributes|
      expect(attributes[:donor_first_name]).to eq 'John'
      expect(attributes[:donor_last_name]).to eq 'Smith'
      expect(attributes[:donor_address_1]).to eq 'the Street 1'
      expect(attributes[:donor_address_2]).to eq 'the Street 2'
      expect(attributes[:donor_city]).to eq 'Denver'
      expect(attributes[:donor_state]).to eq 'CO'
      expect(attributes[:donor_zip]).to eq '12345'
      expect(attributes[:donor_email]).to eq 'johnsmith@gmail.com'
      expect(attributes[:donor_phone]).to eq '123-345-6789'
      expect(attributes[:employer_name]).to eq 'Some Company'
      expect(attributes[:employer_occupation]).to eq 'Manager'
      expect(attributes[:employer_address]).to eq 'the Emp Street'
      expect(attributes[:employer_city]).to eq 'New York City'
      expect(attributes[:employer_state]).to eq 'NY'
      expect(attributes[:employer_zip]).to eq '54321'
      expect(attributes[:cc_number]).to eq '4111111111111111'
      expect(attributes[:cc_cvv]).to eq '123'
      expect(attributes[:cc_month]).to eq '02'
      expect(attributes[:cc_year]).to eq '2019'
    end
  end

  describe 'Class Methods' do
    let!(:profile) { create(:candidate_profile) }
    let!(:de_account) { create(:de_account, profile: profile) }

    it 'shows total amounts for donations created each month' do
      create(:donation, profile: profile, created_at: 4.months.ago, amount: 81)
      create(:donation, profile: profile, created_at: 4.months.ago, amount: 62)

      create(:donation, profile: profile, created_at: 3.months.ago, amount: 95)
      create(:donation, profile: profile, created_at: 3.months.ago, amount: 22)
      create(:donation, profile: profile, created_at: 3.months.ago, amount: 79)

      create(:donation, profile: profile, created_at: 2.months.ago, amount: 51)

      create(:donation, profile: profile, created_at: 1.months.ago, amount: 14)
      create(:donation, profile: profile, created_at: 1.months.ago, amount: 2)
      create(:donation, profile: profile, created_at: 1.months.ago, amount: 32)
      create(:donation, profile: profile, created_at: 1.months.ago, amount: 24)

      Donation.amount_by_month.tap do |all_records|
        all_records[0].tap do |record|
          expect(record.created_at).to eq 4.months.ago.beginning_of_month.to_date
          expect(record.total_amount.to_i).to eq 143
        end

        all_records[1].tap do |record|
          expect(record.created_at).to eq 3.months.ago.beginning_of_month.to_date
          expect(record.total_amount.to_i).to eq 196
        end

        all_records[2].tap do |record|
          expect(record.created_at).to eq 2.months.ago.beginning_of_month.to_date
          expect(record.total_amount.to_i).to eq 51
        end

        all_records[3].tap do |record|
          expect(record.created_at).to eq 1.months.ago.beginning_of_month.to_date
          expect(record.total_amount.to_i).to eq 72
        end
      end
    end

    it 'shows total amounts for each week' do
      create(:donation, profile: profile, created_at: 4.weeks.ago, amount: 44)
      create(:donation, profile: profile, created_at: 4.weeks.ago, amount: 61)

      create(:donation, profile: profile, created_at: 3.weeks.ago, amount: 36)
      create(:donation, profile: profile, created_at: 3.weeks.ago, amount: 60)
      create(:donation, profile: profile, created_at: 3.weeks.ago, amount: 25)

      create(:donation, profile: profile, created_at: 2.weeks.ago, amount: 20)

      create(:donation, profile: profile, created_at: 1.weeks.ago, amount: 98)
      create(:donation, profile: profile, created_at: 1.weeks.ago, amount: 98)
      create(:donation, profile: profile, created_at: 1.weeks.ago, amount: 5)
      create(:donation, profile: profile, created_at: 1.weeks.ago, amount: 24)

      Donation.amount_by_week.tap do |all_records|
        all_records[0].tap do |record|
          expect(record.created_at).to eq 4.weeks.ago.beginning_of_week.to_date
          expect(record.total_amount.to_i).to eq 105
        end

        all_records[1].tap do |record|
          expect(record.created_at).to eq 3.weeks.ago.beginning_of_week.to_date
          expect(record.total_amount.to_i).to eq 121
        end

        all_records[2].tap do |record|
          expect(record.created_at).to eq 2.weeks.ago.beginning_of_week.to_date
          expect(record.total_amount.to_i).to eq 20
        end

        all_records[3].tap do |record|
          expect(record.created_at).to eq 1.weeks.ago.beginning_of_week.to_date
          expect(record.total_amount.to_i).to eq 225
        end
      end
    end

    it 'should switch method' do
      expect(Donation).to receive(:count_by_month)
      Donation.count_by(:month)

      expect(Donation).to receive(:count_by_week)
      Donation.count_by(:week)

      expect(Donation).to receive(:count_by_month)
      Donation.count_by(nil)
    end
  end
end
