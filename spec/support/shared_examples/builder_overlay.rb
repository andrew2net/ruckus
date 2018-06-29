shared_examples 'Builder overlay' do
  describe 'Preview' do
    before { visit builder_overlay_path }

    specify do
      expect(page).to have_css "a#hotspot-tagline[href='#{profile_builder_path(resources: :info)}']"
      expect(page).to have_css "a#hotspot-profile-pic[href='#{profile_builder_path(resources: :media)}']"
      expect(page).to have_css "a#hotspot-account-info[href='#{profile_builder_path(resources: :info)}']"
      expect(page).to have_css "a#hotspot-donations[href='#{profile_builder_path(resources: :info)}']"
      expect(page).to have_css "a#hotspot-biography[href='#{profile_builder_path(resources: :biography)}']"
      expect(page).to have_css "a#hotspot-hero-media[href='#{profile_builder_path(resources: :featured)}']"
      expect(page).to have_css "a#hotspot-issues[href='#{profile_builder_path(resources: :issues)}']"
      expect(page).to have_css "a#hotspot-media-stream[href='#{profile_builder_path(resources: :media)}']"
      expect(page).to have_css "a#hotspot-my-updates[href='#{profile_builder_path(resources: :press)}']"
      expect(page).to have_css "a#hotspot-contact[href='#{profile_builder_path(resources: :info)}']"
      expect(page).to have_css "a#hotspot-tagline-footer[href='#{profile_builder_path(resources: :info)}']"
    end
  end
end
