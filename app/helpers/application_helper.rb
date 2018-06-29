require 'socket'

module ApplicationHelper
  def profile_path(domain_or_profile)
    domain = domain_or_profile.is_a?(Profile) ? domain_or_profile.domain : domain_or_profile
    return root_url if domain.nil?

    if domain.internal?
      root_url(subdomain: domain.name)
    else
      uri = URI.parse(root_url)
      uri.host = domain.name
      uri.to_s
    end
  end

  def year_choices
    (1920..(Date.today.year)).to_a.reverse
  end

  def title(page_title)
    if content_for(:title).present?
      content_for :title, ' | '
    end
    content_for :title, page_title.to_s
  end

  def bodyclasses(body_classes)
    content_for :bodyclasses, body_classes.to_s
  end

  def nav_link(paths, params = {}, &block)
    params[:class] = '' unless  params.has_key?(:class)
    if request.path_info == profile_root_path
      params[:class] += ' active' if paths.include?(request.path_info)
    else
      params[:class] += ' active' if paths.reject{|path| path == profile_root_path}.find{ |path| path == request.path_info }.present?
    end

    link_to paths[0], params do
      capture(&block)
    end
  end

  def goodle_map(latitude, longitude)
    "https://maps.google.com/maps/api/staticmap?size=450x300&sensor=false&zoom=16&markers=#{latitude}%2C#{longitude}"
  end

  def press_release_thumbs_data(press_release)
    images = press_release.press_release_images.to_a

    if images.any?
      image_number = images.index(press_release.active_image) + 1
      yield(images, press_release.active_image, image_number)
    end
  end

  def continue_editing_url
    referer_uri = URI.parse(request.referer.to_s)
    host = referer_uri.host
    path = referer_uri.path.to_s

    if (host == request.domain || host == "www.#{request.domain}") && path.start_with?('/account/')
      request.referer
    else
      profile_root_url(subdomain: nil)
    end
  end

  def clean_url(url)
    URI.parse(url.to_s).host
  end

  def password_min_length
    Rails.application.config.devise.password_length.first
  end

  def media_submit_button_classes(hash_of_attributes)
    hash_of_attributes[:classes] if hash_of_attributes.has_key? :classes
  end

  def ruckus_media?(hash_of_attributes)
    hash_of_attributes.has_key?(:ruckus_media)
  end

  def checkbox_or_radio?(hash_of_attributes)
    hash_of_attributes.has_key?(:checkboxes) ? 'checkbox' : 'radio'
  end

  def contribution_limit(resource)
    resource.profile.de_account.contribution_limit
  end

  def category_color_block_class(category, index)
    index = index % 20 + 1

    "category-#{category.try(:national_security?) ? 'national-security' : (index)}"
  end

  def signups_chart_data(period = :month)
    Account.count_by(period)
  end

  def logins_chart_data(account, period = :month)
    account.logins.count_by(period)
  end

  def visits_chart_data(domain, period = :month)
    domain.visits.count_by(period)
  end

  def donations_count_chart_data(period = :month)
    Donation.count_by(period)
  end

  def donations_amount_chart_data(period = :month)
    Donation.amount_by(period)
  end

  def shorten_to_tweet_length(text)
    truncate(text, length: 143)
  end

  def theme_selection_tag(profile, color)
    active = profile.theme == "theme-#{color}"
    content_tag :span, class: "theme-color-#{color} #{'active' if active}" do
      "#{content_tag :i} #{radio_button_tag :theme, color.to_sym, active}".html_safe
    end
  end

  private

  def last_12_months
    (0..11).to_a.reverse.collect{ |month_offset| month_offset.months.ago.beginning_of_month }
  end
end
