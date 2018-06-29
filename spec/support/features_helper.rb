module FeaturesHelper
  def login_as_admin(admin)
    visit new_admin_session_path
    within('form#new_admin') do
      fill_in 'Email', with: admin.email
      fill_in 'Password', with: admin.password
      find("[value='Sign in']").click
    end
  end

  def login_as_account(user, password = 'secret123')
    visit root_path
    click_on 'Login'

    within('div.login') do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      find("button[type='submit']").click
    end
  end

  def with_subdomain(subdomain, path='/')
    if Capybara.current_driver == :rack_test
      root_url(subdomain: subdomain) + path
    else
      host = 'lvh.me'
      allow_any_instance_of(Figaro::ENV).to receive(:domain).and_return(host)
      host = [subdomain, host].compact.join('.')
      "http://#{host}:#{Capybara.current_session.server.port}#{path}"
    end
  end

  def check_checkbox_with_js(checkbox_id)
    page.execute_script("$('#{checkbox_id}').closest('.check-box').click()")
  end

  def submit_form_with_js(form_id)
    page.execute_script("$('form#{form_id}').submit()")
  end

  def scroll_modal_to(selector)
    page.execute_script "$('.ruckus-modal-body').mCustomScrollbar('scrollTo', '#{selector}', {scrollInertia:0})"
    expect(page).to have_css selector, visible: true
  end

  def check_flash(text)
    within('#flash') { expect(page).to have_content text }
  end

  def js_click(selector)
    page.execute_script("$(\"#{selector}\").click();")
  end

  def hide_welcome_screen
    click_on 'Build my site' if Capybara.current_driver != :rack_test
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop until page.evaluate_script('jQuery.active').zero?
    end
  end
end
