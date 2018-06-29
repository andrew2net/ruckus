require 'rails_helper'

describe DomainNameFetcher do
  let(:fetcher) { DomainNameFetcher.new(request) }
  let(:domain)  { [subdomain, main_domain].compact.join('.') }
  let(:request) { OpenStruct.new(domain: domain.to_s, subdomain: subdomain.to_s) }

  describe 'fetch' do
    context 'built in' do
      let(:main_domain) { 'example.com' }

      context 'with subdomain' do
        let(:subdomain) { 'mysubdomain' }
        specify { expect(fetcher.fetch).to eq 'mysubdomain' }
      end

      context 'without subdomain' do
        let(:subdomain) { nil }
        specify { expect(fetcher.fetch).to eq '' }
      end
    end

    context 'external' do
      let(:main_domain) { 'other.com' }

      context 'with subdomain' do
        let(:subdomain) { 'mysubdomain' }
        specify { expect(fetcher.fetch).to eq 'mysubdomain.other.com' }
      end

      context 'without subdomain' do
        let(:subdomain) { nil }
        specify { expect(fetcher.fetch).to eq 'other.com' }
      end

      context 'with domain ends with main domain' do
        let(:main_domain) { 'locexample.com' }

        context 'without subdomain' do
          let(:subdomain) { nil }
          specify { expect(fetcher.fetch).to eq 'locexample.com' }
        end

        context 'with subdomain' do
          let(:subdomain) { 'subdomain' }
          specify { expect(fetcher.fetch).to eq 'subdomain.locexample.com' }
        end
      end
    end
  end
end
