class AddFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :address_1, :string
    add_column :profiles, :address_2, :string
    add_column :profiles, :campaign_website, :string
    add_column :profiles, :campaign_organization, :string
    add_column :profiles, :contact_city, :string
    add_column :profiles, :contact_state, :string
  end
end
