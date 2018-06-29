class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :url
      t.boolean :primary, default: false
      t.integer :candidate_id
      t.timestamps
    end
  end
end
