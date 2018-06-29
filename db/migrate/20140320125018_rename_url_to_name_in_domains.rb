class RenameUrlToNameInDomains < ActiveRecord::Migration
  def change
    rename_column :domains, :url, :name
  end
end
