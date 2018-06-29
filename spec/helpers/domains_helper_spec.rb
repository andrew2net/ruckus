require 'rails_helper'

describe DomainsHelper do
  describe 'full_domain_url' do
    let(:domain1) { create :domain, name: 'local', internal: true }
    let(:domain2) { create :domain, name: 'external.com', internal: false }

    specify do
      expect(helper.full_domain_url(domain1)).to eq 'http://local.test.host'
      expect(helper.full_domain_url(domain2)).to eq 'http://external.com'
    end
  end
end
