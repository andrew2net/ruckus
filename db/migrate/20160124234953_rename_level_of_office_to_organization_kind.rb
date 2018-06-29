class RenameLevelOfOfficeToOrganizationKind < ActiveRecord::Migration
  def change
    rename_column :de_accounts, :account_level_of_office, :account_organization_kind
  end
end
