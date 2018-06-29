class AddRegisterToVoteUrlToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :register_to_vote_url, :string
    add_column :profiles, :register_to_vote_on, :boolean, default: false
  end
end
