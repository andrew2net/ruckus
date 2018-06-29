require 'mixpanel-ruby'

class MixpanelTracker
  def initialize(account)
    if account.present?
      @account = account.reload
      @profile = @account.candidate_profiles.first || @account.organization_profiles.first
    end
    @events = []
    @issue_title = nil
  end

  def add_event(event_name)
    @events << event_name.to_s if @account.present?
  end

  def track_event(event_name, additional_options = nil)
    add_event event_name
    @additional_options = additional_options
    track
  end

  def track
    if should_track?
      @events.uniq.each do |event_name|
        MixpanelEventSubmitter.perform_async(@account.id, event_name, properties)
      end
    end
  end

  private

  def should_track?
    !(Rails.env.test? || Rails.env.development?)
  end

  def properties
    properties = {}
    if @profile.blank?
      properties = common_properties
    else
      if @profile.type == 'CandidateProfile'
        properties = candidate_properties
      elsif @profile.type = 'OrganizationProfile'
        properties = organization_properties
      end
    end

    properties.merge!(@additional_options) if @additional_options.present?
    properties
  end

  def candidate_properties
    common_properties.merge(
      'candidate_display_name' => @profile.name,
      'candidate_office_name' => @profile.office,
      'candidate_constituency' => @profile.district,
      'candidate_party_affiliation' => @profile.party_affiliation,
      'candidate_tagline' => @profile.tagline
    )
  end

  def organization_properties
    common_properties.merge(
      'org_display_name' => @profile.name,
      'org_tagline' => @profile.tagline
    )
  end

  def common_properties
    result = account_properties

    if @profile.present?
      result.merge!(
        'user_account_type' => account_type,
        'user_admin_first_name' => @profile.first_name,
        'user_admin_last_name' => @profile.last_name,
        'user_admin_address1' => @profile.address_1,
        'user_admin_address2' => @profile.address_2,
        'user_admin_city' => @profile.contact_city,
        'user_admin_state' => @profile.contact_state,
        'user_display_city' => @profile.city,
        'user_display_state' => @profile.state,
        'user_display_zip' => @profile.contact_zip,
        'user_admin_phone' => @profile.phone,
        'user_display_url' => @profile.campaign_website,
        'user_facebook_handle' => facebook_url,
        'user_twitter_handle' => twitter_url,
      )

      if @profile.domain.present?
        result.merge!('user_ruckus_url' => @profile.domain.name)
      end
    end

    result
  end

  def account_properties
    {
      'user_id' => @account.id,
      'user_email' => @account.email,
      'account_status_deactivate_date' => @account.deleted_at.to_s,
      'user_sign_up_date' => @account.created_at.to_s
    }
  end

  def facebook_url
    @profile.facebook_account.present? ? @profile.facebook_account.url : 'N/A'
  end

  def twitter_url
    @profile.twitter_account.present? ? @profile.twitter_account.url : 'N/A'
  end

  def account_type
    @profile.type.gsub('Profile', '')
  end
end
