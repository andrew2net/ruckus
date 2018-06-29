require 'rails_helper'

describe AdminPanelHelper do
  let!(:account1) { create(:account, last_sign_in_at: Time.parse('15/08/2015 16:30')) }
  let!(:account2) { create(:account, last_sign_in_at: nil) }

  specify '#formatted_last_sign_in' do
    expect(formatted_last_sign_in(account1)).to eq '08/15/2015'
    expect(formatted_last_sign_in(account2)).to eq 'N/A'
  end
end
