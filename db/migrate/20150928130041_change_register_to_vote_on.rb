class ChangeRegisterToVoteOn < ActiveRecord::Migration
  class TheProfile < ActiveRecord::Base
    self.table_name = :profiles
  end

  def up
    change_column_default :profiles, :register_to_vote_on, true
    TheProfile.update_all(register_to_vote_on: false) if ruckus?
  end

  def down
    change_column_default :profiles, :register_to_vote_on, false
  end
end
