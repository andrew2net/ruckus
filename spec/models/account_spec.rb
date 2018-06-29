require 'rails_helper'

describe Account do
  describe 'concerns' do
    it_behaves_like 'chartable'
  end

  describe 'associations' do
    it { expect(subject).to have_many(:ownerships) }
    it { expect(subject).to have_many(:admin_ownerships) }
    it { expect(subject).to have_many(:editor_ownerships) }

    it { expect(subject).to have_many(:profiles).through(:ownerships) }
    it { expect(subject).to have_many(:candidate_profiles).through(:ownerships) }
    it { expect(subject).to have_many(:organization_profiles).through(:ownerships) }

    it { expect(subject).to have_many(:profiles).dependent(:destroy) }
    it { expect(subject).to have_many(:logins).dependent(:destroy) }

    it { expect(subject).to belong_to :profile }
    it { expect(subject).to belong_to :candidate_profile }
    it { expect(subject).to belong_to :organization_profile }
  end

  describe 'nested attributes' do
    it { expect(subject).to accept_nested_attributes_for :candidate_profile }
    it { expect(subject).to accept_nested_attributes_for :organization_profile }
  end

  describe '#update' do
    let!(:profile) { create :candidate_profile }
    let!(:account) { create :account, profile: profile }
    let!(:params_with_password) { params.merge(password: 'new-password', password_confirmation: 'new-password') }

    let!(:params) { { email: 'updated-email@example.com' } }

    after do
      account.reload
      expect(account.email).to eq 'updated-email@example.com'
    end

    specify 'with password' do
      account.update(params)
    end

    specify 'without password' do
      account.update(params_with_password)
    end
  end

  describe 'scopes' do
    describe '::admins_first' do
      let!(:admin)      { create :account, profile: profile }
      let!(:ownership1) { create :ownership, profile: profile, account: admin }
      let(:profile)     { create :candidate_profile }
      let!(:editor)     { create :account, profile: profile }
      let!(:ownership2) { create :ownership, profile: profile, account: editor, type: 'EditorOwnership' }

      specify do
        expect(profile.accounts.admins_first).to eq [admin, editor]
      end
    end

    describe 'with_first' do
      let(:account1) { create(:account) }
      let(:account2) { create(:account) }

      specify do
        expect(Account.with_first(account1.id)).to eq [account1, account2]
        expect(Account.with_first(account2.id)).to eq [account2, account1]
      end
    end

    describe '#by_id' do
      let(:account1) { create(:account, email: 'account1@mail.com') }
      let(:account2) { create(:account, email: 'account2@mail.com') }
      let(:account3) { create(:account, email: 'account3@mail.com') }

      specify do
        expect(Account.by_id).to eq [account1, account2, account3]
      end
    end

    describe '::inactive' do
      let!(:credit_card_holder1) { create :credit_card_holder, profile: nil, token: 'token1' }
      let!(:credit_card_holder2) { create :credit_card_holder, profile: profile2, token: 'token1' }
      let(:profile1)  { create :profile, premium_by_default: true  }
      let(:profile2)  { create :profile }
      let(:profile3)  { create :profile }
      let!(:account1) { create :account, profile: profile1 }
      let!(:account2) { create :account, profile: profile1 }
      let!(:account3) { create :account, profile: profile2 }
      let!(:account4) { create :account, profile: profile3 }

      it { expect(described_class.inactive).to contain_exactly(account4) }
    end

    describe '::active' do
      let!(:credit_card_holder) { create :credit_card_holder, profile: profile2, token: 'token1' }
      let(:profile1)  { create :profile, premium_by_default: true  }
      let(:profile2)  { create :profile }
      let(:profile3)  { create :profile }
      let!(:account1) { create :account, profile: profile1 }
      let!(:account2) { create :account, profile: profile1 }
      let!(:account3) { create :account, profile: profile2 }
      let!(:account4) { create :account, profile: profile3 }

      it { expect(described_class.active).to contain_exactly(account1, account2, account3) }
    end
  end
end
