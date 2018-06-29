require 'rails_helper'

describe 'Account::Events' do
  let!(:account) { create :account, profile: profile }
  let!(:profile) { create :candidate_profile }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
    hide_welcome_screen
  end


  describe 'Index', :js do
    let(:now) { Time.new(2015, 3, 13) }
    let!(:event1) do
      create :event, profile: profile,
                     title: 'RMGIUGIT',
                     start_time: now + 2.days
    end

    let!(:event2) do
      create :event, profile: profile,
                     title: 'WHSWQFCR',
                     start_time: now + 1.hour
    end

    let!(:event3) do
      create :event, profile: profile,
                     title: 'INVISIBLE EVENT',
                     start_time: now + 1.month
    end

    before do
      Timecop.travel(now)
      visit profile_builder_path
      within('.admin-subnav') { click_on 'Events' }
      expect(page).to have_css '.ruckus-modal'
    end

    after { Timecop.return }

    specify do
      expect(page).to have_content 'RMGIUGIT'
      expect(page).to have_content 'WHSWQFCR'
      expect(page).to have_no_content 'INVISIBLE EVENT'

      next_month = I18n.l(1.month.from_now.to_date, format: :calendar_date)
      previous_month = I18n.l(1.month.ago.to_date, format: :calendar_date)

      expect(page).to have_link '>', href: profile_events_path(month: next_month)
      expect(page).to have_link '<', href: profile_events_path(month: previous_month)

      within('#events') do
        expect(page).to have_link nil, profile_events_path
      end
    end
  end

  describe 'Create' do
    before do
      within('.admin-subnav') { click_on 'Events' }
      click_on 'Add New Event'
    end

    it 'should create event for a account', :js do
      Timecop.travel(Date.new(2015, 1, 1)) do
        fill_in 'event_title', with: 'My Title'
        fill_in 'event_link_text', with: 'Link text'
        fill_in 'event_link_url', with: 'http://url.com'
        fill_in 'event_address', with: 'My Street'
        fill_in 'event_city', with: 'NYC'
        select 'New York', from: 'event_state'
        fill_in 'event_zip', with: '10001'
        fill_in 'event_description', with: 'Description'
        fill_in 'event_start_time_date', with: '02/23/2016'
        fill_in 'event_start_time_time', with: '3:23PM'
        click_on 'Add'

        expect(page).to have_content 'My Title'
        expect(page).to have_css '#events-switch'
      end
    end

    it 'should display blank errors' do
      fill_in 'event_title', with: ''

      click_on 'Add'
      expect(page).to have_content "can't be blank"
    end
  end

  describe 'Update' do
    let!(:event1) { create(:event, profile: profile, title: 'RMGIUGIT', start_time: now + 5.minutes) }
    let(:now) { Time.new(2015, 3, 15) }


    before do
      Timecop.travel(now)
      visit profile_builder_path
      within('.admin-subnav') { click_on 'Events' }
      within('.ruckus-modal') { click_on 'RMGIUGIT' }
    end

    after { Timecop.return }

    it 'should update event for a account', :js do
      fill_in 'event_title', with: 'Title New'
      fill_in 'event_description', with: 'Boom'
      click_on 'Save'

      expect(page).to have_content 'Title New'
      expect(page).not_to have_content 'RMGIUGIT'
    end

    it 'should display :base errors' do
      fill_in 'event_start_time_date', with: '02/12/2014'
      fill_in 'event_end_time_date', with: '02/12/2013'
      click_on 'Save'

      expect(page).to have_content 'Start time should precede the end time'
    end
  end

  describe 'Destroy' do
    let(:now) { Time.new(2015, 3, 13) }
    let!(:event1) { create(:event, profile: profile, title: 'RMGIUGIT', start_time: now + 5.minutes) }

    before { Timecop.travel(now) }
    after { Timecop.return }

    it 'should destroy records' do
      visit profile_builder_path

      within('.admin-subnav') { click_on 'Events' }
      expect(page).to have_css '.trash'
      expect(page).to have_content 'RMGIUGIT'
      first('.trash').click
      expect(page).not_to have_content 'RMGIUGIT'
    end
  end

  describe 'Collection bugfix' do
    let!(:event1) { create(:event, event_params.merge(title: 'KSJDVNSLK1')) }
    let!(:event2) { create(:event, event_params.merge(title: 'KSJDVNSLK2')) }
    let!(:event3) { create(:event, event_params.merge(title: 'KSJDVNSLK3')) }

    let(:event_params) do
      { profile: profile, start_time: Time.new(2015, 3, 10), end_time: Time.new(2015, 3, 15) }
    end

    before do
      Timecop.travel(Time.new(2015, 3, 13))

      login_as(account, scope: :account)
      visit profile_builder_path
    end

    after { Timecop.return }

    it 'should have View All button, but not an event itself' do
      within '#events-block' do
        expect(page).to have_link 'View All'
        expect(page).to have_no_content 'KSJDVNSLK'
      end
    end

    specify 'update event', :js do
      find('#events-block .i-edit').click

      within '.ruckus-modal-body-content' do
        click_on 'KSJDVNSLK1'
        expect(page).to have_content 'Edit Event'
        click_on 'Save'
      end

      expect(page).to have_no_css '.ruckus-modal-body-content'
    end
  end
end
