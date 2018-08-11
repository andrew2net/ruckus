class CreateCampaingPages < ActiveRecord::Migration
  def change
    create_table :campaing_pages do |t|
      t.string :page_id, not_null: true, index: { unique: true }
      t.string :access_token, not_null: true
      t.string :name, not_null: true
      t.boolean :publishing_on, default: false, not_null: true
      t.references :oauth_account, index: true, not_null: true

      t.timestamps
    end
  end
end
