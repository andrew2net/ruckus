module AdminPanelHelper
  def account_filter_link(name, path)
    content_tag :li, class: "#{'active' if request.env['ORIGINAL_FULLPATH'] == path}" do
      link_to name, path
    end
  end

  def formatted_last_sign_in(account)
    account.last_sign_in_at.present? ? I18n.l(account.last_sign_in_at) : 'N/A'
  end
end
