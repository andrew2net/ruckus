class RemoveDemocracyengineRecipientIdFromCandidates < ActiveRecord::Migration
  def change
    remove_column :candidates, :democracyengine_recipient_id, :string
  end
end
