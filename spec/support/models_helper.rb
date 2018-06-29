module ModelsHelper
  def expect_to_validate_email(attribute_name)
    ['whatever@gmail.com', 'other12_3@gmail.com', 'du.do@gmail.com'].tap do |urls|
      expect(subject).to allow_value(*urls).for(attribute_name)
    end

    ['my url@gmail.com', 'will,ferrell@gmail.com, @#$%^@gmail.com'].each do |value|
      expect(subject).to_not allow_value(value).for(attribute_name)
    end
  end

  def expect_to_validate_domain_format_of(attribute_name)
    expect(subject).to allow_value(
      'a', 'aa', 'aaa', 'domain.com', 'domain.second.com', "#{'a' * 50}.com", 'my-subdomain-1.com',
      'mailchimp', 'ftpchimp', 'wwwchimp', 'popchimp', 'smtpchimp', 'sslchimp', 'sftpchimp', 'httpchimp', 'will-ruck.us'
    ).for(attribute_name)

    ['some.domain.', "some.#{'a' * 64}", 'http.com', 'ftp.com', 'mail.com', 'pop.com', 'smtp.com',
     'ssl.com', 'sftp.com', '-domain', 'https.com', 'site.ruck.us', 'ruck.us', 'devruck.us', 'site.devruck.us'].each do |value|
      expect(subject).to_not allow_value(value).for(attribute_name)
    end
  end

  def expect_to_validate_url_format(attribute_name, service = :any)
    allowed_values = ['https://gmail.com', 'http://aa.ch/', 'http://will-ferrell.ruck.us']
    prohibited_values = ['bad-stuff\nhttps://gmail.com\nmore-bad-stuff', 'url', 'my url',
                         'gmail.com', 'ftp://gmail.com', 'aa.ch', 'will-ferrell.ruck.us']

    case service
      when :facebook_format
        allowed_values = ['https://www.facebook.com/some-page', 'https://www.facebook.com/some_page',
                          'https://www.facebook.com/some.page', 'http://www.facebook.com/some.page',
                          'http://facebook.com/some.page']
        prohibited_values = ['https://wwwafacebookacom/some.page',
                             "bad-stuff\nhttps://www.facebook.com/some.page\nmore-bad-stuff",
                             'http://www.facebook.com/', 'http://www.google.com',
                             'svtp://facebook.com/some.page', 'facebook.com/some.page',
                             any_other_site]
      when :twitter_format
        allowed_values = ['https://twitter.com/some-page', 'https://twitter.com/some_page',
                          'https://twitter.com/some.page', 'http://twitter.com/some.page']
        prohibited_values = ["bad-stuff\nhttps://twitter.com/some.page\nmore-bad-stuff",
                             'http://www.twitter.com/', 'svsv://twitter.com/some.page',
                             'twitter.com/some.page', 'http://www.google.com', any_other_site]
      when :youtube_or_vimeo_video_format
        allowed_values = ['https://www.youtube.com/watch?v=PnqCS4Lvy5E',
                          'http://www.youtube.com/watch?v=PnqCS4Lvy5E',
                           'http://youtube.com/watch?v=PnqCS4Lvy5E',
                           'http://youtube.com/watch?v=PnqCS4Lvy5E',
                           'http://youtu.be/watch?v=PnqCS4Lvy5E',
                           'https://www.youtube.com/watch?v=ZJUfiEFh1w4&list=PLivjPDlt6ApQ8vBgHkeEjeRJjzqUGv9dV',
                           'https://vimeo.com/232323']
        prohibited_values = ['https://vimeoocom/232323', 'https://youtusbe/watch?v=PnqCS4Lvy5E',
                             'https://www.youtubeacom/watch?v=PnqCS4Lvy5E',
                             "ahttps://www.youtube.com/watch?v=PnqCS4Lvy5E",
                             "a\nhttps://www.youtube.com/watch?v=PnqCS4Lvy5E",
                             'hsbp://www.youtube.com/watch?v=PnqCS4Lvy5E',
                             'http://www.youtube.com/watch?v=',
                             'http://www.youtube.com/', 'http://www.vimeo.com/',
                             'ahttps://vimeo.com/232323', "a\nhttps://vimeo.com/232323",
                             any_other_site]
    end

    allowed_values.tap do |urls|
      expect(subject).to allow_value(*urls).for(attribute_name)
    end

    prohibited_values.each do |value|
      expect(subject).to_not allow_value(value).for(attribute_name)
    end
  end

  def expect_to_validate_page_existence(attribute_name, service = :any)
    allowed_values = ['https://gmail.com']
    prohibited_values = []

    case service
      when :facebook
        allowed_values = ['https://www.facebook.com/TimeforaRuck.us']
        prohibited_values = ['https://www.facebook.com/some-non-existent-page123']
      when :twitter
        allowed_values = ['https://twitter.com/theruckus']
        prohibited_values = ['https://twitter.com/some-non-existent-account-234']
      when :video
        allowed_values = ['https://www.youtube.com/watch?v=9bGGDfPRKv4', 'http://vimeo.com/34521']
        prohibited_values = ['https://www.youtube.com/watch?v=non-existent-video-123']
    end

    allowed_values.tap do |urls|
      expect(subject).to allow_value(*urls).for(attribute_name)
    end

    prohibited_values.each do |value|
      expect(subject).to_not allow_value(value).for(attribute_name)
    end
  end


  def expect_to_validate_url_without_schema(attribute_name)
    ['https://gmail.com', 'aa.ch/', 'http://will-ferrell.ruck.us', 'http://sdfsdfsdf.fd'].each do |url|
      expect(subject).to allow_value(url).for(attribute_name)
    end

    ['my url', 'will-ferrell.ruck.us dsasd'].each do |value|
      expect(subject).to_not allow_value(value).for(attribute_name)
    end
  end

  def expect_to_validate_zip_format(attribute_name)
    ['12345', '12345-6789'].each do |good_zip|
      expect(subject).to allow_value(good_zip).for(attribute_name)
    end

    %w(1 12 123 1234 123456 1234567 12345678 123456789 a23456789 1234567890).each do |bad_zip|
      expect(subject).not_to allow_value(bad_zip).for(attribute_name)
    end
  end

  def expect_to_validate_amount_inclusion(attribute_name)
    profile = create(:candidate_profile)
    create(:de_account, profile: profile, contribution_limit: 2500)

    [10, 12.15, 25, 24.32, 50, 100, 500, 1_000, 2_500, 100_000].each do |good_amount|
      donation = build(:donation, profile: profile, amount: good_amount)
      expect(donation).to be_valid
    end

    [500_000, 1_000_000].each do |bad_amount|
      donation = build(:donation, profile: profile, amount: bad_amount)
      expect(donation).not_to be_valid
    end
  end

  def expect_to_validate_format_field(attribute_name)
    ['first', 'second', 'Name'].each do |good_zip|
      expect(subject).to allow_value(good_zip).for(attribute_name)
    end

    %w(/ * ! @ # $ % \ + _ = 0 ?).each do |bad_zip|
      expect(subject).not_to allow_value(bad_zip).for(attribute_name)
    end
  end

  def expect_to_validate_phone_number(attribute_name)
    ['838932832', '3232-3232'].each do |good_phone_number|
      expect(subject).to allow_value(good_phone_number).for(attribute_name)
    end

    ['a', 'dsc3a-dsa', '-3232-323', '-32-32-', '32--3232'].each do |bad_phone_number|
      expect(subject).not_to allow_value(bad_phone_number).for(attribute_name)
    end
  end

  private

  def any_other_site
    "http://www.#{SecureRandom.hex}.com/"
  end
end
