describe require 'rails_helper'

describe Progress::ContactInfo do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile, profile_params) }
  let(:nil_params) do
    { address_1: nil, address_2: nil, phone: nil, contact_city: nil, contact_state: nil, campaign_website: nil }
  end

  after { expect(subject.total_items_count).to eq 1 }

  describe 'without any required fields' do
    let(:profile_params) { nil_params }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 0
      expect(subject.completed_percent).to eq 0
    end
  end

  describe 'with one field filled:' do
    after do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 5
    end

    context 'address_1' do
      let(:profile_params) { nil_params.merge(address_1: 'address_1') }
      specify {}
    end

    context 'address_2' do
      let(:profile_params) { nil_params.merge(address_2: 'address_2') }
      specify {}
    end

    context 'phone' do
      let(:profile_params) { nil_params.merge(phone: '212-121-1212') }
      specify {}
    end

    context 'contact_city' do
      let(:profile_params) { nil_params.merge(contact_city: 'contact_city') }
      specify {}
    end

    context 'contact_state' do
      let(:profile_params) { nil_params.merge(contact_state: 'NY') }
      specify {}
    end

    context 'campaign_website' do
      let(:profile_params) { nil_params.merge(campaign_website: 'http://example.com') }
      specify {}
    end
  end
end
