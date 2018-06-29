class Header::Cell < BaseCell
  self_contained!
  include ActionView::Helpers::DateHelper # time_ago_in_words
  include ApplicationHelper # shorten_to_tweet_length
  include SocialButtonsHelper

  def show
    render
  end

  def show_photo?
    @show_photo ||= profile.photo.present?
  end

  def render_photo
    render partial: show_photo_placeholder? ? 'photo_placeholder' : 'photo'
  end

  def render_question_pencil
    render partial: 'question_pencil' if show_navigation?
  end

  def render_donations_block
    if show_navigation?
      donation_placeholder
    elsif profile.can_accept_donations?
      donation_link
    end
  end

  def social_post_photo_or_placeholder
    if show_social_photo?
      social_post_photo
    elsif show_social_photo_placeholder?
      social_photo_placeholder
    end
  end

  def general_info
    with_dots(general_info_elements)
  end

  def displayed_social_post
    @displayed_social_post ||= profile.social_posts.order(created_at: :desc).first
  end

  def social_post_classes
    "social-feed-meta #{shift_social_class}"
  end

  def photo_classes
    "account-image account-image-#{labels[:type]}"
  end

  def photo_placeholder_classes
    "edit-link js-edit-modal account-image-add account-image-add-#{labels[:type]}"
  end

  # Pending:
  # def show_questions?
  #   account_editing? || questions.exists?
  # end

  private
  def with_dots(array)
    raw array.reject(&:blank?).map(&:to_s).join(content_tag(:span, raw('&bull;')))
  end

  def general_info_elements
    show_general_info_placeholders? ? general_info_placeholders : general_info_array
  end

  def show_general_info_placeholders?
    show_navigation? && general_info_array.reject(&:blank?).empty?
  end

  def general_info_array
    [profile.party_affiliation, profile.district, profile.city_and_state]
  end

  def general_info_placeholders
    ['Party', 'District', 'Location']
  end

  def show_photo_placeholder?
    !show_photo? && show_navigation?
  end

  def donation_placeholder
    profile.de_account.present? ? edit_donation_settings_link : new_de_account_link
  end

  def donation_link
    link_to 'Donate', new_front_profile_donation_path(profile), class: 'btn btn-lg ajax-modal-link'
  end

  def new_de_account_link
    link_to '$', new_profile_de_account_path, class: 'btn-donate'
  end

  def edit_donation_settings_link
    link_to '$', profile_builder_payment_account_path, class: 'edit-link js-edit-modal btn-donate'
  end

  def shift_social_class
    'social-feed-meta-shift' if !profile.candidate? || (profile.photo.blank? && !show_navigation?)
  end

  def social_post_photo
    image_tag profile.photo_url(:small_thumb), alt: profile.name
  end

  def social_photo_placeholder
    content_tag :span, nil, class: 'empty-image'
  end

  def show_social_photo_placeholder?
    show_navigation? && profile.candidate?
  end

  def show_social_photo?
    profile.candidate? && profile.photo.present?
  end
end
