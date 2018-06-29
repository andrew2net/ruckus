class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.string :donor_first_name
      t.string :donor_middle_name
      t.string :donor_last_name
      t.string :donor_email
      t.string :donor_phone
      t.string :donor_address_1
      t.string :donor_address_2
      t.string :donor_city
      t.string :donor_state
      t.string :donor_zip
      t.string :employer_name
      t.string :employer_occupation
      t.string :employer_address
      t.string :employer_city
      t.string :employer_state
      t.string :employer_zip
      t.integer :amount
      t.string :cc_last_four
      t.string :transaction_guid
      t.string :transaction_uri
      t.integer :candidate_id
      t.text :democracyengine_request_errors

      t.timestamps
    end

    add_index :donations, :candidate_id
  end
end
