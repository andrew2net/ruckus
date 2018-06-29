class AskQuestion::Cell < BaseCell
  self_contained!

  # Todo: enable_switcher can be removed.
  # same thing is done with CSS (ask Alex)

  def show
    render if show_ask_question?
  end

  def render_switch
    render partial: 'switch' if show_navigation? && enable_switcher
  end

  def classes
    result = 'btn btn-speech-bubble ajax-modal-link'
    result += ' btn-speech-bubble-arrow' if show_photo_or_placeholder?
    result
  end

  def ask_question_button_photo
    photo_or_placeholder if show_photo_or_placeholder?
  end

  def photo_or_placeholder
    show_photo? ? photo_tag : placeholder_tag
  end

  private
  def show_ask_question?
    show_navigation? || profile.questions_on?
  end

  def show_photo_or_placeholder?
    (show_navigation? && profile.candidate?) || (profile.candidate? && show_photo?)
  end

  def show_photo?
    profile.photo.present?
  end

  def photo_tag
    image_tag profile.photo_url(:small_thumb), alt: profile.name
  end

  def placeholder_tag
    content_tag :span, nil, class: 'empty-image'
  end
end

