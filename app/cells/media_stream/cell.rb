class MediaStream::Cell < BaseCell
  self_contained!

  def show
    render if show_media_stream?
  end

  def render_medium(medium)
    render partial: 'item', locals: { medium: medium }
  end

  def render_switch
    render partial: 'switch' if show_media_stream_switch?
  end

  def render_new_medium_icon
    render partial: 'new_medium_icon' if show_media_stream_switch?
  end

  def render_placeholder_or_block
    render partial: show_media_place_holder? ? 'placeholder' : 'block'
  end

  def media_stream_items
    profile.media_stream_items
  end

  private
  def show_media_stream_switch?
    media_stream_items.any? && show_navigation?
  end

  def show_media_place_holder?
    media_stream_items.empty? && show_navigation?
  end

  def show_media_stream?
    show_navigation? || (profile.media_on? && media_stream_items.exists?)
  end
end
