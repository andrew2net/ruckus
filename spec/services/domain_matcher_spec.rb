require 'rails_helper'

describe DomainMatcher do
  describe '::matches?' do
    let(:request) { Object.new }

    specify 'domain name is fetched' do
      allow(DomainNameFetcher).to receive(:new).with(request).and_return(OpenStruct.new(fetch: 'domain'))
      expect(DomainMatcher.matches?(request)).to eq true
    end

    specify 'domain name is not fetched' do
      allow(DomainNameFetcher).to receive(:new).with(request).and_return(OpenStruct.new(fetch: ''))
      expect(DomainMatcher.matches?(request)).to be_falsey
    end
  end
end
