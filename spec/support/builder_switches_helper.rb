module BuilderSwitchesHelper
  def enables_the_block(switch_id, block_id)
    visit profile_builder_path
    hide_welcome_screen
    expect(page).to have_css "#{block_id}.section-disabled"
    find(switch_id).click
    expect(page).to have_css block_id
    expect(page).to have_no_css "#{block_id}.section-disabled"
    wait_for_ajax

    visit with_subdomain(profile.domain.name)
    expect(page).to have_css block_id
    expect(page).to have_no_css switch_id
  end

  def disables_the_block(switch_id, block_id)
    visit profile_builder_path
    hide_welcome_screen
    expect(page).to have_css block_id
    expect(page).not_to have_css "#{block_id}.section-disabled"
    find(switch_id).click
    expect(page).to have_css "#{block_id}.section-disabled"
    wait_for_ajax

    visit with_subdomain(profile.domain.name)
    expect(page).to have_no_css block_id
    expect(page).to have_no_css switch_id
  end
end
