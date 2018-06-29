class UrlFormatValidator < ActiveModel::EachValidator
  FACEBOOK_FORMAT = /\Ahttps?:\/\/(?:www\.)?facebook\.com\/(?:(?:[\w\.\-\_])+)\z/
  TWITTER_FORMAT = /\Ahttps?:\/\/(?:www\.)?twitter\.com\/(?:(?:[\w\.\-\_])+)\z/
  YOUTUBE_OR_VIMEO_VIDEO_FORMAT = /\Ahttps?:\/\/(?:www\.)?(((youtube\.com|youtu\.be).*(v=)([a-zA-Z0-9_-]{3,})).*|(vimeo\.com).*([0-9]{3,}))\z/

  def validate_each(record, attribute, value)
    if value.present?
      validate_url_format(record, attribute, value)
      validate_url_existence(record, attribute, value) if options[:existence]
    end
  end

  private
  def validate_url_format(record, attribute, value)
    begin
      record.errors[attribute] << 'is not valid URL' unless URI.parse(value).kind_of?(URI::HTTP)
      case options[:format]
        when :facebook
          record.errors[attribute] << 'Invalid Facebook URL' unless value =~ FACEBOOK_FORMAT
        when :twitter
          record.errors[attribute] << 'Invalid Twitter URL' unless value =~ TWITTER_FORMAT
        when :youtube_or_vimeo_video
          record.errors[attribute] << 'Invalid Youtube or Vimeo URL' unless value =~ YOUTUBE_OR_VIMEO_VIDEO_FORMAT
      end
    rescue URI::BadURIError, URI::InvalidURIError
      record.errors[attribute] << 'is not valid URL'
    end
  end

  def validate_url_existence(record, attribute, value)
    if value.present? && record.errors[attribute].empty?
      if options[:format] == :youtube_or_vimeo_video && value =~ /youtu.*be/
        Yt::Video.new(url: value).title
      else
        Mechanize.new.get(value)
      end
    end
  rescue OpenURI::HTTPError, Mechanize::ResponseCodeError, SocketError, Errno::ECONNREFUSED, URI::BadURIError,
    URI::InvalidURIError, Yt::Errors::NoItems, Yt::Errors::RequestError
    record.errors[attribute] << 'Page does not exist'
  rescue RuntimeError
    record.errors[attribute] << 'Page redirected'
  end
end

