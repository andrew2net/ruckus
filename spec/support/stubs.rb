require 'deapi'

RSpec.configure do |config|
  config.before do |example|
    if example.metadata[:unstub_url_existence].blank?
      allow_any_instance_of(UrlFormatValidator).to receive(:validate_url_existence).and_return(true)
    end

    if example.metadata[:unstub_de].blank?
      allow(DEApi).to receive(:create_donation) do
        {
          'token'        => 'token',
          'cc_last_four' => '1234',
          'line_items'   => [
            'transaction_guid' => 'transaction_guid',
            'transaction_uri'  => 'transaction_uri'
          ]
        }
      end

      allow_any_instance_of(De::DonationCreator)
        .to receive(:process)
        .and_return('cc_last_four' => '1234',
                    'line_items' => [{ 'transaction_guid' => '23456789',
                                       'transaction_url' => 'http://www.trancaction.com' }])


      allow(DEApi).to receive(:create_recipient)
    end

    if example.metadata[:unstub_social_posts].blank?
      allow_any_instance_of(SocialPost).to receive(:should_post_to_facebook?).and_return true
      allow_any_instance_of(SocialPost).to receive(:submit_to_facebook)
      allow_any_instance_of(SocialPost).to receive(:remove_from_facebook)
      allow_any_instance_of(SocialPost).to receive(:should_post_to_twitter?).and_return true
      allow_any_instance_of(SocialPost).to receive(:submit_to_twitter)
      allow_any_instance_of(SocialPost).to receive(:remove_from_twitter)
    end

    if example.metadata[:unstub_event_time_validation].blank?
      allow_any_instance_of(Event).to receive(:start_time_is_in_future).and_return true
    end

    if (n = example.metadata[:stub_koala])
      graph = double :graph
      expect(graph).to receive(:get_connections)
        .with('me', 'accounts').and_return(
          [{
            'access_token' => 'page_token',
            'category' => 'Political Organization',
            'category_list' => [{ 'id' => '123', 'name' => 'Political Organization' }],
            'name' => 'Social test page',
            'id' => '2091225817617702',
            'tasks' => %w[ANALYZE ADVERTISE MODERATE CREATE_CONTENT MANAGE]
          }]
        ).exactly(n).times
      expect(Koala::Facebook::API).to receive(:new).with('token').and_return(graph).exactly(n).times
    end
  end
end
