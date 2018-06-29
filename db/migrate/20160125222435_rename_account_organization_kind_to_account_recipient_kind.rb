class RenameAccountOrganizationKindToAccountRecipientKind < ActiveRecord::Migration
  def change
    rename_column :de_accounts, :account_organization_kind, :account_recipient_kind
  end
end
