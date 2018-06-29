class Footer::Cell < BaseCell
  self_contained!
  include SocialButtonsHelper
  include ApplicationHelper # profile_path

  def show
    render
  end

  def disclaimer_or_placeholder
    display_disclaimer_placeholder? ? disclaimer_placeholder : profile.campaign_disclaimer
  end

  def display_contact_info_placeholder?
    no_contact_info? && show_navigation?
  end

  def contact_placeholder
    content_tag :span, 'Contact', class: 'text-placeholder'
  end

  def page_uri_link
    link_to request.env['HTTP_HOST'], target: '_blank' unless ENV['RAILS_ENV'] == 'test'
  end

  private
  def display_disclaimer_placeholder?
    profile.campaign_disclaimer.blank? && show_navigation?
  end

  def disclaimer_placeholder
    content_tag :span, 'Disclaimer', class: 'text-placeholder'
  end

  def no_contact_info?
    [profile.address_1, profile.address_2, contact_city_and_state, profile.phone].none?(&:present?)
  end

  def contact_city_and_state
    state_with_zip = [profile.contact_state, profile.contact_zip].select(&:present?).join(' ')
    [profile.contact_city, state_with_zip].select(&:present?).join(', ')
  end
end
