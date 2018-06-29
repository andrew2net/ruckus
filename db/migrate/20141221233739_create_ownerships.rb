class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.references :account, index: true
      t.references :profile, index: true
      t.boolean :primary, default: false

      t.timestamps
    end
  end
end
