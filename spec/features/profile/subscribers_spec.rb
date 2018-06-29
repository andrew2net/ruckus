require 'rails_helper'

describe 'Builder' do
  let!(:profile)         { create :candidate_profile }
  let!(:account)         { create :account, profile: profile }
  let!(:good_subscriber) { create :user, subscribed: true }
  let!(:bad_subscriber)  { create :user, subscribed: false }
  let!(:good_subscription) do
    create(:subscription, profile:  profile,
                          user:       good_subscriber,
                          created_at: Time.parse('Fri, 25 Apr 2014 22:36:23 UTC +00:00'))
  end
  let!(:bad_subscription)  { create(:subscription, profile: profile, user: bad_subscriber) }

  before do
    login_as(account, scope: :account)
    visit profile_subscriptions_path
  end

  describe 'Subscriber Actions' do
    it 'can see list of ALL subscribers' do
      #click_on 'ALL'
      expect(page).to have_content good_subscriber.email
      expect(page).to have_content "#{good_subscriber.first_name} #{good_subscriber.last_name}"
      expect(page).to have_content '04/25/2014'
      expect(page).to have_no_content bad_subscriber.email
    end

    #describe 'Filters' do
    #  it 'can see list of SUBSCRIBED subscribers' do
    #    click_on 'SUBSCRIBED'
    #    expect(page).to have_content 'good_subscriber@gmail.com'
    #    expect(page).to have_no_content 'bad_subscriber@gmail.com'
    #  end
    #
    #  it 'can see list of SUBSCRIBED subscribers' do
    #    click_on 'UNSUBSCRIBED'
    #    expect(page).to have_no_content 'good_subscriber@gmail.com'
    #    expect(page).to have_content 'bad_subscriber@gmail.com'
    #  end
    #
    #  it 'can search search subscribers by email' do
    #    fill_in 'search', with: 'good'
    #    click_on 'Search'
    #    expect(page).to have_content 'good_subscriber@gmail.com'
    #    expect(page).to have_no_content 'bad_subscriber@gmail.com'
    #  end
    #end

    #it 'can create subscribers' do
    #  click_on 'Add new subscriber'
    #
    #  within '#subscriber_form' do
    #    fill_in 'Email', with: 'test@gmail.com'
    #    click_on 'Save'
    #  end
    #
    #  expect(account.subscribers.where(email: 'test@gmail.com')).to be_any
    #end
    #
    #it 'can edit subscribers' do
    #  click_on 'good_subscriber@gmail.com'
    #
    #  within '#subscriber_form' do
    #    fill_in 'Email', with: 'very_good_subscriber@gmail.com'
    #    click_on 'Save'
    #  end
    #
    #  expect(good_subscriber.reload.email).to eq 'very_good_subscriber@gmail.com'
    #end
    #
    #it 'can destroy subscribers' do
    #  within 'table.subscribers' do
    #    first(:link, 'Destroy').click
    #  end
    #
    #  expect(page).to have_content 'good_subscriber@gmail.com'
    #  expect(page).to have_no_content 'bad_subscriber@gmail.com'
    #end

    #it 'can subscribe unsubscribed subscribers back' do
    #  expect(bad_subscriber.subscribed).to be_falsey
    #
    #  click_on 'Subscribe Back'
    #
    #  expect(bad_subscriber.reload).to be_subscribed
    #end
  end
end
