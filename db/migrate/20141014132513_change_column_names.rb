class ChangeColumnNames < ActiveRecord::Migration
  # todo: remove educations?
  # todo: remove experiences?
  # todo: are pages still required?

  def up
    rename_column :democracyengine_accounts, :account_name, :account_full_name
    rename_column :democracyengine_accounts, :account_account_committee_name, :account_committee_name
    rename_column :democracyengine_accounts, :account_district_locality, :account_district_or_locality
    rename_column :democracyengine_accounts, :max_donation_cap, :contribution_limit
    rename_column :democracyengine_accounts, :bank_account_nickname, :bank_account_name

    change_column :democracyengine_accounts, :account_campaign_disclaimer, :text

    rename_column :profiles, :slogan, :tagline
    rename_column :profiles, :about_me, :biography
  end

  def down
    rename_column :democracyengine_accounts, :account_full_name, :account_name
    rename_column :democracyengine_accounts, :account_committee_name, :account_account_committee_name
    rename_column :democracyengine_accounts, :account_district_or_locality, :account_district_locality
    rename_column :democracyengine_accounts, :contribution_limit, :max_donation_cap
    rename_column :democracyengine_accounts, :bank_account_name, :bank_account_nickname

    change_column :democracyengine_accounts, :account_campaign_disclaimer, :string

    rename_column :profiles, :tagline, :slogan
    rename_column :profiles, :biography, :about_me
  end
end
