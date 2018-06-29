require 'rails_helper'

describe LabelsDictionary do
  let(:labels) { LabelsDictionary.new(profile) }

  after { expect(labels[:missing_sample]).to eq 'Missing sample' }

  describe 'candidate' do
    let(:profile) { build(:candidate_profile) }

    specify do
      expect(labels[:type]).to eq 'candidate'
      expect(labels[:name]).to eq 'Your Name'
    end
  end

  describe 'organization' do
    let(:profile) { build(:organization_profile) }

    specify do
      expect(labels[:type]).to eq 'organization'
      expect(labels[:name]).to eq 'Organization Name'
    end
  end
end
