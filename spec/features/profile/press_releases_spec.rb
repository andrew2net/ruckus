require 'rails_helper'

describe 'My Press' do
  let(:profile) { create :candidate_profile }
  let!(:account) { create :account, profile: profile }
  let!(:press_release1) { create :press_release, profile: profile }
  let!(:press_release2) { create :press_release, profile: profile }
  let!(:press_release3) { create :press_release, profile: profile, title: 'Fine Title' }
  let!(:press_release4) { create :press_release, profile: profile }
  let!(:link) { 'http://www.ted.com/talks/clayton_cameron_a_rhythm_etic_the_math_behind_the_beats' }

  before do
    PressRelease.update_positions([press_release3.id, press_release1.id, press_release2.id])

    login_as(account, scope: :account)
    visit profile_builder_path
    hide_welcome_screen
  end

  specify 'Index' do
    within('.admin-subnav') { click_on 'Press' }
    expect(page).to have_css '.ruckus-modal'
    expect(page).to have_css "#press-release-#{press_release3.id} + #press-release-#{press_release1.id} + #press-release-#{press_release2.id}"

    [press_release1, press_release2, press_release3].each do |press_release|
      expect(page).to have_link(press_release.title, href: edit_profile_press_release_path(press_release))
    end
    expect(page).to have_css "#press-release-#{press_release1.id} .trash"

    find("#press-release-#{press_release1.id} .trash").click
    expect(page).not_to have_css("#press-release-#{press_release1.id}")
  end

  describe 'Create' do
    before do
      within('.admin-subnav') { click_on 'Press' }
      click_on 'Add New Press Link'
    end

    specify 'success', :js do
      expect(page).to have_link('Cancel', href: profile_press_releases_path)
      within('#update-url-curl') { fill_in 'curl-url', with: link }
      click_on 'Add'

      within '#update-form' do
        fill_in 'Page Heading', with: 'Press release test page heading'
      end

      expect(page).to have_field 'Page Heading'

      submit_form_with_js '#update-form'

      expect(page).not_to have_field 'Page Heading'

      within('#press') do
        expect(page).to have_content 'Press release test page heading'
      end

      expect(page).to have_css '#press-switch'
    end

    specify 'success with really long title', :js do
      within('#update-url-curl') { fill_in 'curl-url', with: 'http://www.mlive.com/news/ann-arbor/index.ssf/2014/09/whitmore_lake_schools_annexati_2.html#incart_river' }
      click_on 'Add'

      expect(page).to have_field 'Page Heading'
      submit_form_with_js '#update-form'

      expect(page).to have_no_field 'Page Heading'
    end

    specify 'failure (could not parse)', :js do
      fill_in 'curl-url', with: 'invalid url'
      click_on 'Add'

      expect(page).to have_content 'invalid link'
    end

    specify 'failure (non existent link)', :js do
      fill_in 'curl-url', with: 'http://non-existent-link-123456fdfsbg.com'
      click_on 'Add'

      expect(page).to have_content 'service not found'
    end

    specify 'failure (empty field)', :js do
      fill_in 'curl-url', with: link
      submit_form_with_js '#update-url-curl'

      expect(page).to have_content 'Page Heading'

      fill_in 'Page Heading', with: ''
      click_on 'Add'

      expect(page).to have_content "can't be blank"
    end

    xspecify 'failure with PDF file', :js do
      fill_in 'curl-url', with: 'http://cran.r-project.org/doc/manuals/R-intro.pdf'
      submit_form_with_js '#update-url-curl'

      fill_in 'Page Heading', with: 'Some title'
      expect(page).to have_content 'only html pages allowed'
      click_on 'Add'

      expect(page).to have_content 'only html pages allowed'
    end
  end

  describe 'Update' do
    before do
      within('.admin-subnav') { click_on 'Press' }
      click_on 'Fine Title'
    end

    specify 'success', :js do
      fill_in 'Page Heading', with: 'Some New Title'
      click_on 'Update'

      expect(page).to have_no_field 'Page Heading'

      within('#press') do
        expect(page).not_to have_content 'Fine Title'
        expect(page).to have_content 'Some New Title'
      end
    end

    specify 'failure (display errors)' do
      fill_in 'Page Heading', with: ''
      click_on 'Update'

      expect(page).to have_content "can't be blank"
    end
  end
end
