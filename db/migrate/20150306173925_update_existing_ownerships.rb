class UpdateExistingOwnerships < ActiveRecord::Migration
  class TheOwnership < ActiveRecord::Base
    self.table_name = 'ownerships'
  end

  def up
    TheOwnership.update_all type: 'AdminOwnership'
  end

  def down; end
end
