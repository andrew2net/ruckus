require 'rails_helper'

describe 'Social Posts' do
  let!(:account) { create :account, profile: profile }
  let!(:profile) { create :candidate_profile, first_name: 'Bob', last_name: 'Dob' }
  let!(:social_post_1) do
    create :social_post, profile: profile,
                         created_at: 2.hours.ago,
                         message: 'Molestias quas ipsum est.'
  end
  let!(:social_post_2) do
    create :social_post, profile: profile,
                         created_at: 4.hours.ago,
                         message: 'Libero quia quibusdam sit maiores aut aut aut.'
  end

  describe 'displaying list of social posts' do
    before { visit front_profile_social_posts_path(profile) }

    it 'should have account info' do
      within '.social-feed-modal' do
        expect(page).to have_content 'Bob Dob'
      end

      expect(page).to have_no_css '.new_post'
    end

    it 'should have all posts' do
      within '.social-feed-modal' do
        expect(page).to have_content '2 hours ago'
        expect(page).to have_content 'Molestias quas ipsum est.'

        expect(page).to have_content '4 hours ago'
        expect(page).to have_content 'Libero quia quibusdam sit maiores aut aut aut.'
      end
    end
  end

  specify 'displaying OG tags' do
    visit front_profile_social_post_path(profile, social_post_1)

    expect(page).to have_selector :xpath, '//head/meta[@property="fb:app_id"]', visible: false
    expect(page).to have_selector :xpath, '//head/meta[@property="og:site_name"]', visible: false
    expect(page).to have_selector :xpath, '//head/meta[@property="og:type"]', visible: false
    expect(page).to have_selector :xpath, '//head/meta[@property="og:title"]', visible: false
    expect(page).to have_selector :xpath, '//head/meta[@property="og:description"]', visible: false
    expect(page).to have_selector :xpath, '//head/meta[@property="og:url"]', visible: false
  end
end
