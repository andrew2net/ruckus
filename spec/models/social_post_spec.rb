require 'rails_helper'

describe SocialPost do
  let!(:profile) { create :candidate_profile }
  let!(:facebook_account) { create(:oauth_account, profile: profile, provider: 'facebook') }

  it { expect(subject).to belong_to :profile }
  it { expect(subject).to have_many(:scores) }
  it { expect(subject).to have_many(:oauth_accounts).through(:profile) }

  describe 'Facebook', :unstub_social_posts do
    describe '#facebook_post_allowed?' do
      let(:social_post) { build :social_post, provider: ['facebook'], profile: profile }

      it 'allows to submit to Facebook' do
        allow_any_instance_of(Koala::Facebook::API)
          .to receive(:get_connection).with('me', 'permissions')
          .and_return [{ 'permission' => 'publish_pages', 'status' => 'granted' }]

        expect_any_instance_of(SocialPost).to receive(:submit_to_facebook)

        expect(social_post).to be_valid
      end

      it 'does not allow to submit to Facebook if user denied it' do
        allow_any_instance_of(Koala::Facebook::API)
          .to receive(:get_connection).with('me', 'permissions')
          .and_return [{ 'permission' => 'publish_actions', 'status' => 'denied' }]

        expect_any_instance_of(SocialPost).not_to receive(:submit_to_facebook)
        expect(social_post).to be_invalid
      end

      it 'does not allow to submit to Facebook if for some reason it is nil' do
        allow_any_instance_of(Koala::Facebook::API)
          .to receive(:get_connection).with('me', 'permissions')
          .and_return [{ }]

        expect_any_instance_of(SocialPost).not_to receive(:submit_to_facebook)
        expect(social_post).to be_invalid
      end

      it 'does not allow to submit to Facebook if connection is not allowed' do
        allow_any_instance_of(Koala::Facebook::API).to receive(:get_connection).and_raise Koala::Facebook::AuthenticationError.new(nil, nil)
        expect_any_instance_of(SocialPost).not_to receive(:submit_to_facebook)
        expect(social_post).to be_invalid
        expect(social_post.errors[:facebook]).to include 'Need to connect to Facebook'
      end

      it 'does not allow to submit to Facebook if lengh validation failed' do
        expected_result = [{ 'permission' => 'publish_pages', 'status' => 'granted' }]
        allow_any_instance_of(Koala::Facebook::API).to receive(:get_connection).and_return expected_result
        social_post.message = 'a' * 50_000
        expect_any_instance_of(SocialPost).not_to receive(:submit_to_facebook)
        expect(social_post).to be_invalid
        expect(social_post.errors[:message]).to include 'for Facebook allows only 40,000 characters'
        expect(social_post.errors[:facebook]).to be_empty
      end
    end

    describe '#should_post_to_facebook' do
      let(:good_post) { build(:social_post, provider: ['facebook'], profile: profile) }
      let(:bad_post) { build(:social_post, provider: ['twitter'], profile: profile) }

      it 'should post to facebook if it is facebook' do
        allow_any_instance_of(SocialPost).to receive(:facebook_post_allowed?).and_return true
        expect(good_post.send(:should_post_to_facebook?)).to be_truthy
        expect(bad_post.send(:should_post_to_facebook?)).to be_falsey
      end

      it 'should post to facebook if posting is allowed' do
        allow_any_instance_of(SocialPost).to receive(:facebook_post_allowed?).and_return true
        expect(good_post.send(:should_post_to_facebook?)).to be_truthy
      end

      it 'should not post to facebook if posting is disallowed' do
        allow_any_instance_of(SocialPost).to receive(:facebook_post_allowed?).and_return false
        expect(good_post.send(:should_post_to_facebook?)).to be_falsey
      end
    end

    describe '#submit_to_facebook' do
      let(:social_post) do
        create :social_post, message: 'hello world',
                             provider: ['facebook'],
                             facebook_remote_id: nil,
                             profile: profile
      end

      before do
        create :campaing_page, oauth_account: facebook_account, publishing_on: true
        allow_any_instance_of(SocialPost).to receive(:should_post_to_facebook?).and_return true
      end

      it 'should send data to FB' do
        expect_any_instance_of(Koala::Facebook::API)
          .to receive(:put_connections).with('me', 'feed', message: 'hello world')
          .and_return('id' => '100004757554391_286152791553304')
        expect(social_post.reload.campaing_page_posts.last.remote_id).to eq '100004757554391_286152791553304'
      end
    end

    describe '#remove_from_facebook', :old_feature do
      let(:social_post) { create :social_post, profile: profile, provider: ['facebook'], facebook_remote_id: '123' }

      it 'should remove from facebook' do
        allow_any_instance_of(SocialPost).to receive(:should_post_to_facebook?).and_return true
        allow_any_instance_of(SocialPost).to receive(:submit_to_facebook).and_return true
        expect_any_instance_of(Koala::Facebook::API).to receive(:delete_object).with('123').and_return(true)
        social_post.destroy
      end

      it 'should catch the exception if it has already been removed from facebook' do
        allow_any_instance_of(SocialPost).to receive(:should_post_to_facebook?).and_return true
        allow_any_instance_of(SocialPost).to receive(:submit_to_facebook).and_return true
        expect_any_instance_of(Koala::Facebook::API).to receive(:delete_object).with('123').and_raise Koala::Facebook::ClientError.new(nil, nil)
        social_post.destroy
      end
    end
  end

  describe 'Twitter', :unstub_social_posts do
    describe '#twitter_post_allowed?' do
      let(:social_post) { build :social_post, provider: ['twitter'], profile: profile }

      it 'allows to submit to Twitter' do
        allow_any_instance_of(Twitter::REST::Client).to receive_message_chain(:user, :followers_count).and_return 0
        expect_any_instance_of(SocialPost).to receive(:submit_to_twitter)
        expect(social_post).to be_valid
      end

      it 'does not allow to submit to Twitter if authentication failed' do
        allow_any_instance_of(Twitter::REST::Client).to receive(:user).and_raise Twitter::Error::Forbidden
        expect_any_instance_of(SocialPost).not_to receive(:submit_to_twitter)
        expect(social_post).to be_invalid
        expect(social_post.errors[:twitter]).to include 'Need to connect to Twitter'
      end

      it 'does not allow to submit to Twitter if posting not allowed' do
        allow_any_instance_of(Twitter::REST::Client).to receive(:user).and_raise Twitter::Error::Unauthorized
        expect_any_instance_of(SocialPost).not_to receive(:submit_to_twitter)
        expect(social_post).to be_invalid
        expect(social_post.errors[:twitter]).to include 'Need to allow posting at Twitter account'
      end

      it 'does not allow to submit to Twitter if lengh validation failed' do
        allow_any_instance_of(Twitter::REST::Client).to receive_message_chain(:user, :followers_count).and_return 0
        social_post.message = 'a' * 500
        expect_any_instance_of(SocialPost).not_to receive(:submit_to_twitter)
        expect(social_post).to be_invalid
        expect(social_post.errors[:message]).to include 'for Twitter allows only 140 characters'
        expect(social_post.errors[:twitter]).to be_empty
      end
    end

    describe '#should_post_to_twitter' do
      let(:good_post) { build(:social_post, provider: ['twitter'], profile: profile) }
      let(:bad_post) { build(:social_post, provider: ['facebook'], profile: profile) }

      it 'should post to twitter if it is twitter' do
        allow_any_instance_of(SocialPost).to receive(:twitter_post_allowed?).and_return true
        expect(good_post.send(:should_post_to_twitter?)).to be_truthy
        expect(bad_post.send(:should_post_to_twitter?)).to be_falsey
      end

      it 'should post to twitter if posting is allowed' do
        allow_any_instance_of(SocialPost).to receive(:twitter_post_allowed?).and_return true
        expect(good_post.send(:should_post_to_twitter?)).to be_truthy
      end

      it 'should not post to twitter if posting is disallowed' do
        allow_any_instance_of(SocialPost).to receive(:twitter_post_allowed?).and_return false
        expect(good_post.send(:should_post_to_twitter?)).to be_falsey
      end
    end

    describe '#submit_to_twitter' do
      let(:social_post) do
        create :social_post, message: 'hello world',
                             provider: ['twitter'],
                             twitter_remote_id: nil,
                             profile: profile
      end

      before { allow_any_instance_of(SocialPost).to receive(:should_post_to_twitter?).and_return true }

      it 'should send data to FB' do
        expect_any_instance_of(Twitter::REST::Client)
          .to receive(:update).with('hello world')
          .and_return(Twitter::Tweet.new(id: '1234567890'))
        expect(social_post.reload.twitter_remote_id).to eq '1234567890'
      end
    end

    describe '#remove_from_twitter', :old_feature do
      let(:social_post) { create :social_post, profile: profile, provider: ['twitter'], twitter_remote_id: '123' }

      it 'should remove from twitter' do
        allow_any_instance_of(SocialPost).to receive(:should_post_to_twitter?).and_return true
        allow_any_instance_of(SocialPost).to receive(:submit_to_twitter).and_return true
        expect_any_instance_of(Twitter::REST::Client).to receive(:destroy_tweet).with('123').and_return(true)
        social_post.destroy
      end

      it 'should handle the exception that tweet has already been removed' do
        allow_any_instance_of(SocialPost).to receive(:should_post_to_twitter?).and_return true
        allow_any_instance_of(SocialPost).to receive(:submit_to_twitter).and_return true
        expect_any_instance_of(Twitter::REST::Client).to receive(:destroy_tweet).with('123').and_raise Twitter::Error::NotFound
        social_post.destroy
      end
    end
  end

  describe 'message length validation' do
    describe 'twitter' do
      let(:good_message) { build :social_post, provider: ['twitter'], message: 'a' * 15 }
      let(:long_message) { build :social_post, provider: ['twitter'], message: 'a' * 200 }

      before do
        expect(good_message).to receive(:should_post_to_twitter?).and_return true
        expect(long_message).to receive(:should_post_to_twitter?).and_return false

        expect(good_message).to receive(:submit_to_twitter)
        expect(long_message).not_to receive(:submit_to_twitter)
      end

      it 'should take first 140 characters' do
        expect(good_message).to be_valid
        expect(long_message).to be_invalid
        expect(long_message.errors[:message]).to include 'for Twitter allows only 140 characters'
      end
    end

    describe 'facebook' do
      let(:good_message) do
        build :social_post, provider: ['facebook'],
                            message: 'a' * 15,
                            profile: profile
      end
      let(:long_message) do
        build :social_post, provider: ['facebook'],
                            message: 'a' * 50_000,
                            profile: profile
      end

      before do
        expect(good_message).to receive(:should_post_to_facebook?).and_return true
        expect(long_message).to receive(:should_post_to_facebook?).and_return false

        expect(good_message).to receive(:submit_to_facebook)
        expect(long_message).not_to receive(:submit_to_facebook)
      end

      it 'should take first 140 characters' do
        # According to Facebook Dev documentation - maximum limit is 60_000.
        # But started getting errors after 40_000.
        expect(good_message).to be_valid
        expect(long_message).to be_invalid
        expect(long_message.errors[:message]).to include 'for Facebook allows only 40,000 characters'
      end
    end
  end

  describe '#social_errors & #has_social_errors?' do
    let(:post) { build(:social_post) }

    specify 'without errors' do
      expect(post.social_errors).to be_empty
      expect(post).to_not have_social_errors
    end

    specify 'with twitter error' do
      post.errors[:twitter] << 'Twitter error'

      expect(post.social_errors).to eq ['Twitter error']
      expect(post).to have_social_errors
    end

    specify 'with facebook error' do
      post.errors[:facebook] << 'Facebook error'

      expect(post.social_errors).to eq ['Facebook error']
      expect(post).to have_social_errors
    end

    specify 'with facebook & twitter errors' do
      post.errors[:facebook] << 'Facebook error'
      post.errors[:facebook] << 'Facebook error2'
      post.errors[:twitter] << 'Twitter error'
      post.errors[:twitter] << 'Twitter error2'

      post.social_errors.tap do |errors|
        expect(errors).to include 'Facebook error', 'Facebook error2', 'Twitter error', 'Twitter error2'
        expect(errors.count).to eq 4
      end
      expect(post).to have_social_errors
    end
  end

  describe '#deactivate_oauth_accounts!' do
    let!(:facebook_account) { create(:oauth_account, :facebook, profile: profile) }
    let!(:twitter_account)  { create(:oauth_account, :twitter,  profile: profile) }

    describe 'simple post' do
      let(:post) { create(:social_post, provider: [], profile: profile) }

      specify do
        post.errors[:facebook] << 'Error1'
        post.errors[:twitter]  << 'Error2'
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_active
        expect(twitter_account.reload).to  be_active
      end
    end

    describe 'facebook post' do
      let(:post) { create(:social_post, provider: %w(facebook), profile: profile) }

      specify 'without errors' do
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_active
        expect(twitter_account.reload).to  be_active
      end

      specify 'with errors' do
        post.errors[:facebook] << 'Error1'
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_inactive
        expect(twitter_account.reload).to  be_active
      end
    end

    describe 'twitter post' do
      let(:post) { create(:social_post, provider: %w(twitter), profile: profile) }

      specify 'without errors' do
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_active
        expect(twitter_account.reload).to  be_active
      end

      specify 'with errors' do
        post.errors[:twitter] << 'Error1'
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_active
        expect(twitter_account.reload).to  be_inactive
      end
    end

    describe 'facebook & twitter post' do
      let(:post) { create(:social_post, provider: %w(facebook twitter), profile: profile) }

      specify 'without errors' do
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_active
        expect(twitter_account.reload).to  be_active
      end

      specify 'with twitter error' do
        post.errors[:twitter] << 'Error1'
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_active
        expect(twitter_account.reload).to  be_inactive
      end

      specify 'with facebook error' do
        post.errors[:facebook] << 'Error1'
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_inactive
        expect(twitter_account.reload).to  be_active
      end

      specify 'with facebook & twitter errors' do
        post.errors[:facebook] << 'Error1'
        post.errors[:twitter]  << 'Error2'
        post.deactivate_oauth_accounts!

        expect(facebook_account.reload).to be_inactive
        expect(twitter_account.reload).to  be_inactive
      end
    end
  end
end
