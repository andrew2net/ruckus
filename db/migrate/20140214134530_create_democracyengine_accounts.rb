class CreateDemocracyengineAccounts < ActiveRecord::Migration
  def change
    create_table :democracyengine_accounts do |t|
      t.integer :candidate_id
      t.string :email
      t.string :candidate_name
      t.string :candidate_candidate_committee_name
      t.string :candidate_committee_id
      t.string :candidate_address
      t.string :candidate_city
      t.string :candidate_state
      t.string :candidate_zip
      t.string :candidate_level_of_office
      t.string :candidate_office_sough
      t.string :candidate_district_locality
      t.string :candidate_campaign_disclaimer
      t.integer :max_donation_cap
      t.boolean :show_employer_name,    default: true
      t.boolean :show_employer_address, default: true
      t.boolean :show_occupation,       default: true
      t.string :bank_account_nickname
      t.string :bank_routing_number
      t.string :bank_account_number
      t.string :contact_first_name
      t.string :contact_last_name
      t.string :contact_address
      t.string :contact_city
      t.string :contact_state
      t.string :contact_zip
      t.string :contact_email
      t.string :contact_phone
      t.string :uuid

      t.timestamps
    end

    add_index :democracyengine_accounts, :candidate_id
  end
end
