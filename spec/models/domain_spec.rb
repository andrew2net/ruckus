require 'rails_helper'

describe Domain do
  it 'should have associations' do
    expect(subject).to belong_to(:profile)
    expect(subject).to have_many(:accounts).through(:profile).source(:accounts)
    expect(subject).to have_many(:visits).dependent(:destroy)
  end

  describe 'should have validations' do
    let!(:account) { create(:candidate_profile).account }

    before { allow_any_instance_of(Domain).to receive(:account).and_return account }

    it { expect(subject).to validate_presence_of(:profile_id) }
    it { expect(subject).to validate_uniqueness_of(:name) }
    it { expect_to_validate_domain_format_of(:name) }
  end

  describe 'observers' do
    describe 'before_validation:lowercase' do
      let!(:domain) { create :domain, name: 'UppweCaseWords' }

      specify { expect(domain.reload.name).to eq 'uppwecasewords' }
    end

    specify 'before_validation:set_internal' do
      domain = build(:domain, name: 'some-domain', internal: nil)

      domain.valid?
      expect(domain.internal).to be_truthy

      domain.name = 'some-domain.com'
      domain.internal = nil
      domain.valid?
      expect(domain.internal).to be_falsey
    end

    describe 'before_validation:generate_name' do
      let(:profile) { create(:candidate_profile, name: 'John Smith John Smith John Smith John Smith John Smith') }

      specify 'creating name for new accounts' do
        profile.domains.create(new_account: true)

        expect(profile.domain.name).to eq 'john-smith-john-smith-joh'
      end

      specify 'validation error when account is not new' do
        domain = profile.domains.new

        expect(domain).to be_invalid
        expect(domain.errors[:name]).to include "can't be blank"
      end

      context 'generate domain with special symbols' do
        let(:name) { 'Caddo / Bossier Federation of Democratic Women' }
        let(:profile) { create(:organization_profile, name: name) }

        specify do
          expect(profile.reload.domain.name).to eq 'caddo-bossier-federation'
        end
      end
    end

    describe 'before_validation:add_hash' do
      specify 'should add hash' do
        account = create :account, email: 'testemail@example.com'

        profile1 = create :candidate_profile, name: 'John Smith'
        profile2 = create :candidate_profile, account: account, name: 'John Smith'

        expect(profile1.domain.name).to eq 'john-smith'
        expect(profile2.domain.name).to start_with 'john-smith-'
      end

      specify 'should not add hash if it is not a new account' do
        account = create :account, email: 'testemail@gmail.com'
        profile = create :candidate_profile, name: 'John Smith', account: account
        domain = profile.domains.new name: 'john-smith'

        expect(domain).to be_invalid
        expect(domain.errors[:name]).to include 'has already been taken'
      end
    end

    describe 'before destroy' do
      let(:profile) { create(:candidate_profile) }
      let(:domain) { profile.domain }

      context 'external' do
        before { domain.update(internal: false) }


        context 'should destroy' do
          let!(:other_domain) { create(:domain, profile: profile) }

          specify do
            expect { expect(domain.destroy).to be_truthy }.to change(Domain, :count).by(-1)
          end
        end

        specify 'should not destroy' do
          expect { expect(domain.destroy).to be_falsey }.to_not change(Domain, :count)
        end
      end

      context 'internal' do
        before { domain.update(internal: true) }
        let!(:external_domain) { create(:domain, profile: profile, internal: false) }

        context 'should destroy' do
          let!(:other_domain) { create(:domain, profile: profile, internal: true) }

          specify do
            expect { expect(domain.destroy).to be_truthy }.to change(Domain, :count).by(-1)
          end
        end

        specify 'should not destroy' do
          expect { expect(domain.destroy).to be_falsey }.to_not change(Domain, :count)
        end
      end
    end
  end

  describe 'scopes' do
    describe '::internal & ::external' do
      specify do
        domain2 = create(:domain, internal: false)
        domain3 = create(:domain, internal: false)

        expect(Domain.internal.internal).to be_truthy

        Domain.external.tap do |domains|
          expect(domains.size).to eq 2
          expect(domains).to include domain2, domain3
        end
      end
    end
  end

  describe 'methods' do
    let(:domain1) { build(:domain, name: 'some-domain.ru', internal: nil) }
    let(:domain2) { build(:domain, name: SERVER_IP, internal: nil) }
    let(:domain3) { build(:domain, name: 'some-domain.ru', internal: false) }
    let(:domain4) { build(:domain, name: SERVER_IP, internal: false) }
    let(:domain5) { build(:domain, internal: true) }

    specify 'verified?' do
      expect(domain1).not_to be_verified
      expect(domain2).to be_verified
      expect(domain3).not_to be_verified
      expect(domain4).to be_verified
      expect(domain5).to be_verified
    end
  end
end
