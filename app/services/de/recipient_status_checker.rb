class De::RecipientStatusChecker
  require 'deapi'

  def initialize(de_account)
    @uuid = de_account.uuid
  end

  def is_active?
    info = DEApi.show_recipient(@uuid)
    info.present? && info['status'] == 'active'
  end
end
