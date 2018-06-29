class SetInvitationAccepted < ActiveRecord::Migration
  class TheAccount < ActiveRecord::Base
    self.table_name = 'accounts'
  end

  def up
    TheAccount.where.not(encrypted_password: nil).each do |account|
      account.update_columns invitation_created_at: Time.now,
                             invitation_sent_at: Time.now,
                             invitation_accepted_at: Time.now
    end
  end

  def down
  end
end
