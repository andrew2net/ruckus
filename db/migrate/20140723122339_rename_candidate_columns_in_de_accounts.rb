class RenameCandidateColumnsInDeAccounts < ActiveRecord::Migration
  def change
    rename_column :democracyengine_accounts, :candidate_name, :account_name

    rename_column :democracyengine_accounts, :candidate_candidate_committee_name, :account_account_committee_name
    rename_column :democracyengine_accounts, :candidate_committee_id, :account_committee_id
    rename_column :democracyengine_accounts, :candidate_address, :account_address
    rename_column :democracyengine_accounts, :candidate_city, :account_city
    rename_column :democracyengine_accounts, :candidate_state, :account_state
    rename_column :democracyengine_accounts, :candidate_zip, :account_zip
    rename_column :democracyengine_accounts, :candidate_level_of_office, :account_level_of_office
    rename_column :democracyengine_accounts, :candidate_office_sough, :account_office_sough
    rename_column :democracyengine_accounts, :candidate_district_locality, :account_district_locality
    rename_column :democracyengine_accounts, :candidate_campaign_disclaimer, :account_campaign_disclaimer
    rename_column :democracyengine_accounts, :candidate_party, :account_party
  end
end
