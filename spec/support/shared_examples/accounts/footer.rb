shared_examples 'profile page footer' do
  it 'should have sign up link', :js do
    visit with_subdomain(profile.domain.name)

    click_on 'Accounts Start Here'
    expect(page).to have_content 'Create an account as'
  end
end
