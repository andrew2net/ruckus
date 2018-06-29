class CreateSupportMessages < ActiveRecord::Migration
  def change
    create_table :support_messages do |t|
      t.string :subject
      t.string :email
      t.string :name
      t.text :message

      t.timestamps
    end
  end
end
