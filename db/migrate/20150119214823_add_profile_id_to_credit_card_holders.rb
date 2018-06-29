class AddProfileIdToCreditCardHolders < ActiveRecord::Migration
  def up
    add_column :credit_card_holders, :profile_id, :integer
    remove_column :profiles, :credit_card_holder_id

    add_index 'credit_card_holders', ['profile_id'], name: 'index_credit_card_holders_on_profile_id', using: :btree
  end

  def down
    add_column :profiles, :credit_card_holder_id, :integer
    remove_column :credit_card_holders, :profile_id

    add_index 'profiles', ['credit_card_holder_id'], name: 'index_profiles_on_credit_card_holder_id', using: :btree
  end
end
