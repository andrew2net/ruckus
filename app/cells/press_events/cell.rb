class PressEvents::Cell < BaseCell
  self_contained!

  def show
    render if show_press_or_events?
  end

  def render_events
    render partial: 'events_block' if show_events?
  end

  def render_press
    render partial: 'press_block' if show_press?
  end

  def render_press_pencil
    render partial: 'press_pencil' if show_navigation?
  end

  def render_events_pencil
    render partial: 'events_pencil' if show_navigation?
  end

  def render_events_switch
    render partial: 'events_switch' if show_events_switch?
  end

  def render_press_switch
    render partial: 'press_switch' if show_press_switch?
  end

  def render_event(event)
    if event.present?
      render partial: 'event', locals: { event: event }
    else
      render partial: 'event_placeholder'
    end
  end

  def render_press_release(press_release, index)
    if press_release.present?
      render partial: 'press_release', locals: { press_release: press_release, index: index }
    else
      render partial: 'press_release_placeholder'
    end
  end

  def render_view_all_events_link
    view_all_events_link if show_view_all_events_button?
  end

  def render_view_all_press_releases_link
    view_all_press_link if show_view_all_press_releases_button?
  end

  def show_press_or_events?
    show_navigation? || (show_press? || show_events?)
  end

  def show_press?
    @press_exist ||= profile.press_releases.exists?
    show_navigation? || (profile.press_on? && @press_exist)
  end

  def show_events?
    @events_exist ||= profile.events.exists?
    show_navigation? || (profile.events_on? && @events_exist)
  end

  def press_events_classes
    classes = ['section']
    classes << 'press-only' if (show_press? && !show_events?)
    classes << 'events-only' if (show_events? && !show_press?)
    classes.join(' ')
  end

  def press_release_classes(press_release, index)
    classes = ['press']
    classes << 'featured' if index == 0
    classes << 'without_thumbnail' if index != 0 || !press_release.display_page_thumbnail?
    classes.join(' ')
  end

  def events_classes
    "section-editable #{show_press? ? 'col-sm-6' : 'col-sm-12'}"
  end

  def press_classes
    "section-editable #{show_events? ? 'col-sm-6' : 'col-sm-12'}"
  end

  def press
    @press ||= profile.press_releases.by_position.limit(2)
    show_navigation? ? [@press.first, @press.second] : @press
  end

  def events
    @events ||= profile.events.upcoming.earliest_first.limit(2)
    show_navigation? ? [@events.first, @events.second] : @events
  end

  def earliest_possible_event
    @earliest_possible_event ||= events.first || profile.events.first
  end

  private

  def show_view_all_events_button?
    @events_count ||= profile.events.count
    @events_count > 2
  end

  def show_view_all_press_releases_button?
    @press_count ||= profile.press_releases.count
    @press_count > 2
  end

  def show_press_switch?
    show_navigation? && press.any?
  end

  def show_events_switch?
    show_navigation? && profile.events.any?
  end

  def view_all_events_link
    link_to 'View All', front_profile_events_path(profile, event_id: earliest_possible_event.id), class: 'ajax-modal-link' if earliest_possible_event.present?
  end

  def view_all_press_link
    link_to 'View All', front_profile_press_releases_path(profile), class: 'ajax-modal-link'
  end
end
