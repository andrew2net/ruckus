require 'rails_helper'

describe DeAccountStatusChecker do
  let(:profile) { create(:candidate_profile) }
  let!(:account) { profile.account }
  let!(:de_account) { create(:de_account, profile: profile) }
  let(:worker) { DeAccountStatusChecker.new }

  it 'should activate an account when it is ready' do
    allow(DEApi).to receive(:show_recipient).and_return('status' => 'active')

    worker.perform(de_account.id)
    expect(de_account.reload.is_active_on_de).to be_truthy
  end

  it 'should fail - to retry later, if account is not ready' do
    allow(DEApi).to receive(:show_recipient).and_return('status' => 'something else')

    expect {worker.perform(de_account.id, Time.now)}.to change(DeAccountStatusChecker.jobs, :size).by(1)
  end
end
