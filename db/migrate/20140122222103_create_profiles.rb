class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :office
      t.string :slogan
      t.string :city
      t.string :state
      t.string :party_affiliation
      t.string :constituency
      t.integer :user_id

      t.timestamps
    end
  end
end
