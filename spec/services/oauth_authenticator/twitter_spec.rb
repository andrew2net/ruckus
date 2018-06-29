require 'rails_helper'

describe OauthAuthenticator::Twitter do
  subject { described_class.new(profile, auth_data) }
  let(:profile) { create(:candidate_profile) }
  let(:auth_data) { OmniAuth.config.mock_auth[:twitter] }
  let(:other_account) { create(:oauth_account, profile: profile, provider: 'twitter') }

  describe '#process' do
    context 'valid data' do
      after do
        profile.oauth_accounts.last.tap do |account|
          expect(account.uid).to eq 'uid'
          expect(account.oauth_token).to eq 'token'
          expect(account.oauth_secret).to eq 'secret'
          expect(account.oauth_expires_at).to be > 9.years.from_now
          expect(account.url).to eq 'https://twitter.com/fillwerrell'
        end
      end

      specify 'create' do
        expect { expect(subject.process).to be_truthy }.to change{ profile.oauth_accounts.count }.by(1)
      end

      context 'update' do
        let!(:account) { other_account }
        specify { expect { expect(subject.process).to be_truthy }.to_not change(OauthAccount, :count) }
      end
    end

    context 'invalid data' do
      let(:auth_data) { nil }

      specify 'create' do
        expect { expect(subject.process).to be_falsey }.to_not change(OauthAccount, :count)
      end

      context 'update' do
        let!(:account) { other_account }
        specify do
          expect { expect(subject.process).to be_falsey }.to_not change(OauthAccount, :count)
          expect(profile.oauth_accounts).to eq [account]
        end
      end
    end
  end

  specify '#provider_name' do
    expect(subject.provider_name).to eq 'twitter'
  end
end
