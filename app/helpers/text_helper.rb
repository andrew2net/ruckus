module TextHelper
  def donation_engine
    "#{ruckus? ? 'Democracy Engine' : 'Online Fundraising, LLC'}"
  end
end
