require 'rails_helper'

describe ProfilesStat do
  let!(:account1)   { create :account, email: 'email1@example.com', profile: profile1 }
  let!(:account2)   { create :account, email: 'email2@example.com', profile: profile2 }
  let!(:ownership1) { create :ownership, account: account1, profile: profile1 }
  let!(:ownership2) { create :ownership, account: account2, profile: profile2 }
  let!(:ownership3) { create :ownership, account: account2, profile: profile3 }

  let!(:profile1) do
    create(:candidate_profile, :without_domain, default_params(1).merge(donations_on: true))
  end
  let!(:domain11) { create(:domain, profile: profile1) }
  let!(:request111) { create(:request, requestable: domain11) }

  let!(:profile2) do
    create(:organization_profile, :without_domain, default_params(2).merge(donations_on: false))
  end
  let!(:domain21) { create(:domain, profile: profile2) }
  let!(:domain22) { create(:domain, profile: profile2) }
  let!(:request211) { create(:request, requestable: domain21) }
  let!(:request212) { create(:request, requestable: domain22) }

  let!(:profile3) do
    create(:candidate_profile, :without_domain, default_params(3).merge(premium_by_default: true))
  end

  let!(:de_account1) { create(:de_account, is_active_on_de: true, profile: profile1) }
  let!(:de_account2) { create(:de_account, is_active_on_de: true, profile: profile2) }

  let!(:coupon) { create(:coupon, code: 'hello123') }
  let!(:donation) { create(:donation, profile: profile1) }
  let!(:issue_category) { create(:issue_category, profile: profile1) }
  let!(:issue) { create(:issue, profile: profile1, issue_category: issue_category) }
  let!(:medium) { create(:medium, profile: profile2) }

  let!(:credit_card_holder1) { create(:credit_card_holder, profile: profile1, token: nil, coupon: coupon) }
  let!(:credit_card_holder2) { create(:credit_card_holder, profile: profile2, token: 'some-token') }

  before do
    2.times do
      create(:event, profile: profile2)
      create(:press_release, profile: profile1)
    end
  end

  specify '#export' do
    expect(subject.export).to eq [
      %w(email id type name party_affiliation office city state address_1 address_2 district contact_zip donations_on
         donations_amount donations_count events_count issues_count media_count press_count premium premium_by_default
         suspended visits_count coupon_id created_at last_visit).join(','),
      # ['email1@example.com', profile1.id, 'CandidateProfile', 'name1', 'party_affiliation1', 'office1', 'city1', 'AK',
      #  'address_11', 'address_21', 'district1', '11111', 'Yes', '10.0', '1', '', '1', '', '2', 'No', 'No', '1', 'hello123',
      #  profile1.created_at.strftime('%Y-%m-%d %H:00:00')].join(','),
      ['email2@example.com', profile2.id, 'OrganizationProfile', 'name2', 'party_affiliation2', 'office2', 'city2',
       'AZ', 'address_12', 'address_22', 'district2', '11112', 'No', '', '', '2', '', '1', '', 'Yes', 'No', 'No', '2', '',
       profile2.created_at.strftime('%Y-%m-%d %H:00:00'),
       profile2.account.last_sign_in_at && profile2.account.last_sign_in_at.strftime('%Y-%m-%d %H:00:00')].join(','),
      ['email2@example.com', profile3.id, 'CandidateProfile', 'name3', 'party_affiliation3', 'office3', 'city3', 'AR',
       'address_13', 'address_23', 'district3', '11113', 'No', '', '', '', '', '', '', 'Yes', 'Yes', 'No', '', '',
       profile3.created_at.strftime('%Y-%m-%d %H:00:00'),
       profile2.account.last_sign_in_at && profile3.account.last_sign_in_at.strftime('%Y-%m-%d %H:00:00')].join(',')
    ].join("\n") + "\n"
  end

  def default_params(n)
    {
      name:              "name#{n}",
      party_affiliation: "party_affiliation#{n}",
      office:            "office#{n}",
      city:              "city#{n}",
      state:             US_STATES_ABBREVIATIONS[n],
      address_1:         "address_1#{n}",
      address_2:         "address_2#{n}",
      district:          "district#{n}",
      contact_zip:       "1111#{n}"
    }
  end
end
