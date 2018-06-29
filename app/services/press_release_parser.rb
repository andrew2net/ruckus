require 'open-uri'
require 'nokogiri'

class PressReleaseParser
  IMAGE_MIN_SIZE = 50 * 1024
  attr_accessor :errors

  def initialize(url)
    begin
      @url = url.to_s.strip

      validate_url(@url)

      agent = Mechanize.new
      agent.get(@url)
      @page = agent.page
      @errors = { url: 'only html pages allowed' } if @page.header['content-type'] !~ /text\/html/
    rescue Mechanize::ResponseReadError => e
      @page = e.force_parse
    rescue Mechanize::ResponseCodeError, SocketError
      @errors = { url: 'service not found' }
    rescue URI::BadURIError, URI::InvalidURIError
      @errors = { url: 'invalid link' }
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, OpenSSL::SSL::SSLError
      @errors = { url: 'connection refused' }
    rescue OpenURI::HTTPError
      @errors = { url: 'not found' }
    end
  end

  def scrape
    {
      title:       title,
      page_title:  page_title,
      page_date:   page_date,
      url:         @url
    }
  end

  def valid?
    @page.present? && @errors.nil?
  end

  def images
    @images ||= valid? ? @page.search('img').map { |img_tag| image(img_tag) }.compact : []
  end

  private
  def title
    @title ||= valid? ? @page.search('h1').first.try(:text).try(:strip) : ''
  end

  def page_title
    @page_title ||= valid? ? @page.title : ''
  end

  def page_date
    @page_date ||= Time.now.strftime('%d %B %Y')
  end

  def validate_url(url)
    raise URI::InvalidURIError unless URI.parse(url).kind_of?(URI::HTTP)
  end

  def image(img_tag)
    src = img_tag.attribute('src').try(:value)

    if src.present? && allowed_img_src?(src)
      image = open(src)
      image if image.size >= IMAGE_MIN_SIZE
    end

  rescue URI::InvalidURIError, Errno::ENOENT, OpenURI::HTTPError, Errno::ECONNRESET, RuntimeError,
      OpenSSL::SSL::SSLError
    nil
  end

  def allowed_img_src?(src)
    path = URI.parse(src.to_s).path.to_s
    BaseUploader::EXTENSION_WHITE_LIST.any? { |extension| path.ends_with?(".#{extension}") }
  rescue URI::InvalidURIError, Errno::ENOENT, OpenURI::HTTPError, Errno::ECONNRESET, RuntimeError,
      OpenSSL::SSL::SSLError
    nil
  end
end
