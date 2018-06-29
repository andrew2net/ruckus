class Front::PagesController < Front::BaseController
  before_action :build_support_message_instance, only: :contact

  def faq
    @content = get_page_content('faq')
  end

  def terms
    @content = get_page_content('terms')
  end

  def contact
    @content = get_page_content('contact')
    @support_message = SupportMessage.new
  end

  def how_to_update_domain
    @content = get_page_content('how-to-update-domain')
  end

  private
  def build_support_message_instance
    @support_message = SupportMessage.new
  end

  def get_page_content(slug)
    Page.where(slug: slug).first.try(:data).to_s.html_safe
  end
end
