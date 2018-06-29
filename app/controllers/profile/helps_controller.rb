class Profile::HelpsController < Profile::BaseController
  def show
    @faq = Page.where(name: 'faq').first.try(:data).to_s.html_safe
  end
end
