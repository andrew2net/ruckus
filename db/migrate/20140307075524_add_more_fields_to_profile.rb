class AddMoreFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :contact_zip, :string
    add_column :profiles, :campaign_organization_identifier, :string
  end
end
