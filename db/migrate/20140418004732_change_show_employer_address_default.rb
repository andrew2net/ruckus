class ChangeShowEmployerAddressDefault < ActiveRecord::Migration
  def up
    change_column_default :democracyengine_accounts, :show_employer_address, false
  end

  def down
    change_column_default :democracyengine_accounts, :show_employer_address, true
  end
end
