class Event < ActiveRecord::Base
  include Cacheable
  attr_accessor :start_time_date, :start_time_time, :end_time_date, :end_time_time

  belongs_to :profile
  has_many :scores, as: :scorable

  validate :set_start_time
  validate :set_end_time
  validate :start_time_presence
  validate :start_time_is_in_future
  validate :start_time_is_before_end_time

  validates :title, presence: true
  validates :link_url, url_format: true
  validates :city, presence: true
  validates :state, presence: true, inclusion: { in: US_STATES_ABBREVIATIONS }
  validates :time_zone, presence: true, inclusion: { in: TIME_ZONES.keys }
  validates :zip, zip_format: true

  scope :upcoming,       -> { where('start_time > ?', Time.now) }
  scope :by_month,       -> (month) { where('extract(month from start_time) = ?', month) }
  scope :by_year,        -> (year) { where('extract(year from start_time) = ?', year) }
  scope :same_month,     -> (event) { by_year(event.start_time.year).by_month(event.start_time.month) }
  scope :archive,        -> { where('start_time < ?', Time.now) }
  scope :earliest_first, -> { order(:start_time) }

  geocoded_by :location

  after_validation :geocode
  after_validation :set_show_start_time
  after_validation :set_show_end_time

  def newer_event
    cached_method(:newer_event) { profile.events.where('start_time > ?', start_time).order('start_time DESC').last }
  end

  def older_event
    cached_method(:older_event) { profile.events.where('start_time < ?', start_time).order('start_time DESC').first }
  end

  def address_and_city
    [address, city].select(&:present?).join(', ')
  end

  def city_and_state
    [city, state].compact.join(', ')
  end

  def location
    [address, city, state].compact.join(', ')
  end

  def start_time
    self[:start_time].in_time_zone(TIME_ZONES[time_zone]) if self[:start_time].present?
  end

  def end_time
    self[:end_time].in_time_zone(TIME_ZONES[time_zone]) if self[:end_time].present?
  end

  private
  def start_time_is_in_future
    if start_time.present? && start_time < Time.now
      errors[:base] << 'Start time should be in future'
    end
  end

  def start_time_is_before_end_time
    if start_time.present? && end_time.present? && start_time >= end_time
      errors[:base] << 'Start time should precede the end time'
    end
  end

  def start_time_presence
    errors[:base] << 'Start time is required' if start_time.blank?
  end

  def set_start_time
    set_time('start')
  end

  def set_end_time
    set_time('end')
  end

  def to_parser_format(date)
    month, day, year = date.split('/')
    [day, month, year].join('/')
  end

  def set_show_start_time
    self.show_start_time ||= start_time_time.present?
  end

  def set_show_end_time
    self.show_end_time ||= end_time_time.present?
  end

  def to_time_string(date, time)
    time_str = time.present? ? time : I18n.l(5.minutes.from_now, format: :hours_and_minutes)
    [to_parser_format(date), time_str].join(' ')
  end

  def set_time(type)
    date = self.send "#{type}_time_date".to_sym
    time = self.send "#{type}_time_time".to_sym

    if date.present?
      Time.use_zone(TIME_ZONES[time_zone]) do
        time_string = to_time_string(date, time)
        time = Time.zone.parse time_string

        if time_string.present? && time.blank?
          errors[:base] << "#{type.humanize} time is invalid"
        else
          self.send('[]=', "#{type}_time", time)
        end
      end
    end
  end
end
