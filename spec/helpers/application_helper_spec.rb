require 'rails_helper'

describe ApplicationHelper do
  describe '#continue_editing_url' do
    before do
      helper.request.host = "account.#{helper.request.host}"
      allow_any_instance_of(ActionDispatch::Request).to receive(:referer).and_return(referer)
    end

    describe 'with nil referer' do
      let(:referer) { nil }
      specify { expect(helper.continue_editing_url).to eq 'http://test.host/profile' }
    end

    describe 'with an external URL' do
      let(:referer) { 'http://google.com' }
      specify { expect(helper.continue_editing_url).to eq 'http://test.host/profile' }
    end

    describe 'with other account page URL' do
      let(:referer) { 'http://other-account.test.host/account/something' }
      specify { expect(helper.continue_editing_url).to eq 'http://test.host/profile' }
    end

    describe 'with admin area URL with subdomain' do
      let(:referer) { 'http://account.test.host/account/something' }
      specify { expect(helper.continue_editing_url).to eq 'http://test.host/profile' }
    end

    describe 'with admin area URL without subdomain' do
      let(:referer) { 'http://test.host/account/something' }
      specify { expect(helper.continue_editing_url).to eq 'http://test.host/account/something' }
    end
  end

  describe '#clean_url' do
    describe 'normal account link' do
      let(:url) { 'http://my-subdomain.devruck.us' }
      specify { expect(helper.clean_url(url)).to eq 'my-subdomain.devruck.us' }
    end

    describe 'normal account link but not root' do
      let(:url) { 'http://my-subdomain.devruck.us/some_page.html' }
      specify { expect(helper.clean_url(url)).to eq 'my-subdomain.devruck.us' }
    end

    describe 'normal account link with port' do
      let(:url) { 'http://my-subdomain.devruck.us:3000' }
      specify { expect(helper.clean_url(url)).to eq 'my-subdomain.devruck.us' }
    end

    describe 'secure account link with port' do
      let(:url) { 'https://my-subdomain.devruck.us:3000' }
      specify { expect(helper.clean_url(url)).to eq 'my-subdomain.devruck.us' }
    end

    describe 'link without subdomain' do
      let(:url) { 'http://devruck.us' }
      specify { expect(helper.clean_url(url)).to eq 'devruck.us' }
    end
  end

  specify '#category_color_block_class' do
    category = build(:issue_category, name: 'National Security')

    expect(helper.category_color_block_class(category, 0)).to eq 'category-national-security'
    category.name = 'Some name'
    expect(helper.category_color_block_class(category, 0)).to eq 'category-1'
    expect(helper.category_color_block_class(category, 22)).to eq 'category-3'
    expect(helper.category_color_block_class(category, 39)).to eq 'category-20'
  end
end
