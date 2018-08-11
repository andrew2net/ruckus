require 'rails_helper'

describe OauthAuthenticator::Facebook do
  subject { described_class.new(profile, auth_data) }
  let(:profile) { create(:candidate_profile) }
  let(:auth_data) { OmniAuth.config.mock_auth[:facebook] }
  let(:other_account) { create(:oauth_account, profile: profile, provider: 'facebook') }

  describe '#process' do
    context 'valid data' do
      after do
        profile.oauth_accounts.last.tap do |account|
          expect(account.uid).to eq 'uid'
          expect(account.oauth_token).to eq 'token'
          expect(account.oauth_secret).to eq 'secret'
          expect(account.oauth_expires_at).to eq Time.at(1_321_747_205)
          expect(account.url).to eq 'https://www.facebook.com/uid'
        end
      end

      specify 'create', stub_koala: 1 do
        expect do
          account = subject.process
          expect(account).to be_truthy
          expect(account.campaing_pages.count).to be > 0 
        end.to change { profile.oauth_accounts.count }.by(1)
      end

      context 'update', stub_koala: 1 do
        let!(:account) { other_account }
        specify do
          expect do
            expect(subject.process).to be_truthy
          end.to_not change(OauthAccount, :count)
        end
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
    expect(subject.provider_name).to eq 'facebook'
  end
end
