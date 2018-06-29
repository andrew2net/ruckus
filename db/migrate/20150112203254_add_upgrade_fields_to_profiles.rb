class AddUpgradeFieldsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :upgrade_payment_token, :string
    add_column :profiles, :upgrade_cc_last_four, :string
    add_column :profiles, :upgrade_cc_exp_date, :date
    add_column :profiles, :upgrade_errors, :text
  end
end
