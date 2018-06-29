class AddCampaignDisclaimerToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :campaign_disclaimer, :string
  end
end
