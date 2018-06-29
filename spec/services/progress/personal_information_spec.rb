describe require 'rails_helper'

describe Progress::PersonalInformation do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile, profile_params) }
  let(:nil_params) { { city: nil, state: nil, party_affiliation: nil, district: nil, office: nil } }

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

    context 'city' do
      let(:profile_params) { nil_params.merge(city: 'NY') }
      specify {}
    end

    context 'state' do
      let(:profile_params) { nil_params.merge(state: 'NY') }
      specify {}
    end

    context 'party_affiliation' do
      let(:profile_params) { nil_params.merge(party_affiliation: 'party_affiliation') }
      specify {}
    end

    context 'district' do
      let(:profile_params) { nil_params.merge(district: 'district') }
      specify {}
    end

    context 'office' do
      let(:profile_params) { nil_params.merge(office: 'office') }
      specify {}
    end
  end
end
