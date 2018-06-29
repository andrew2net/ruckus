class AddUrlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :link_text, :string
    add_column :events, :link_url, :text
  end
end
