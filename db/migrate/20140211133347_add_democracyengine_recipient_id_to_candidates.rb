class AddDemocracyengineRecipientIdToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :democracyengine_recipient_id, :string
    add_index :candidates, :democracyengine_recipient_id, unique: true
  end
end
