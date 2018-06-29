class RenameEndorsementToPressRelease < ActiveRecord::Migration
  # we thought press_releases are press.
  # but they are different things
  def self.up
    rename_table :endorsements, :press_releases
  end

  def self.down
    rename_table :press_releases, :endorsements
  end
end
