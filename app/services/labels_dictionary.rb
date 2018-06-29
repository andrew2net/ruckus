class LabelsDictionary
  def initialize(profile)
    @type = profile.type.to_s.underscore
    @class = profile.class
  end

  def [](key)
    I18n.t(key, scope: [:labels, @type], default: @class.human_attribute_name(key))
  end
end
