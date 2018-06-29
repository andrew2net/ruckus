require 'rails_helper'

describe De::RecipientStatusChecker do
  let(:profile) { create(:candidate_profile) }
  let!(:account) { profile.account }
  let!(:de_account) { create(:de_account, profile: profile) }
  let!(:check_recipient) { De::RecipientStatusChecker.new(de_account) }

  describe '#initialize' do
    it 'should set object varialbes correctly' do
      expect(check_recipient.instance_variable_get(:@uuid)).to eq de_account.uuid
    end
  end

  describe '#is_active?' do
    it 'should return true if active' do
      allow(DEApi).to receive(:show_recipient).and_return('status' => 'active')
      expect(check_recipient.is_active?).to be_truthy
    end

    it 'should return false if not active' do
      allow(DEApi).to receive(:show_recipient).and_return('status' => 'not active')
      expect(check_recipient.is_active?).to be_falsey
    end
  end
end
