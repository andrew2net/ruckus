module EventsHelper
  def start_time_date(event)
    event.start_time.present? ? I18n.l(event.start_time) : ''
  end

  def start_time_time(event)
    if event.start_time.present? && event.show_start_time?
      I18n.l(event.start_time, format: :default_hours)
    else
      ''
    end
  end

  def end_time_date(event)
    event.end_time.present? ? I18n.l(event.end_time) : ''
  end

  def end_time_time(event)
    if event.end_time.present? && event.show_end_time?
      I18n.l(event.end_time, format: :default_hours)
    else
      ''
    end
  end

  def time_for_events_modal(event)
    if event.show_start_time?
      time_zone = TIME_ZONES[event.time_zone]
      result = l(event.start_time.in_time_zone(time_zone), format: :event_modal_hours)
      result += "-#{l(event.end_time.in_time_zone(time_zone), format: :event_modal_hours)}" if event.end_time.present? && event.show_end_time?
      result
    else
      'N/A'
    end
  end

  def time_in_dashboard(event)
    required_format = 'events_in_dashboard'
    required_format += '_without_time' unless event.show_start_time?

    I18n.l event.start_time, format: required_format.to_sym, address: event.city_and_state
  end

  def google_map(latitude, longitude)
    image_tag "https://maps.google.com/maps/api/staticmap?size=450x300&sensor=false&zoom=16&markers=#{latitude}%2C#{longitude}"
  end

  def previous_month_date(date)
    I18n.l date.beginning_of_month - 1, format: :calendar_date
  end

  def next_month_date(date)
    I18n.l date.end_of_month + 1, format: :calendar_date
  end

  def event_link(event)
    if event.link_url.present?
      link_text = truncate(event.link_text.present? ? event.link_text : event.link_url, length: 32)
      link_to link_text, event.link_url, target: '_blank'
    end
  end
end
