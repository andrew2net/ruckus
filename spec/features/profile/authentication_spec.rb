require 'rails_helper'

xdescribe 'Authentication' do
  describe 'password recovery', :js do
    let(:profile) { create :candidate_profile }
    let(:account) { create :account, profile: profile }

    before do
      visit root_path
      click_on 'Login'
      click_on 'Forgot Password'
      expect(page).to have_selector '.forgot-password-form'
    end

    specify 'send password recovery email' do
      within '.forgot-password-form' do
        fill_in 'account_email', with: account.email
        click_on 'Submit'
      end

      expect(page).to have_content 'PASSWORD RESET INSTRUCTIONS SUCCESSFULLY SENT'
      expect(page).not_to have_selector '.forgot-password-form'
    end

    specify 'unknown email' do
      within '.forgot-password-form' do
        fill_in 'account_email', with: 'strange_email@gmail.com'
        click_on 'Submit'
      end

      expect(page).to have_content 'EMAIL NOT FOUND'
    end
  end

  describe 'sign in', :js do
    let(:profile) { create :candidate_profile }
    let(:account) { create :account, profile: profile }

    specify 'success' do
      login_as_account(account)

      expect(page).to have_content 'SIGNED IN SUCCESSFULLY.'
      expect(page).to have_no_content 'Login'

      visit root_path
      expect(page).to have_no_content 'Start Building Now'

      expect(account.logins.count).to eq 1
      expect(account.logins.first.data.symbolize_keys.keys).to eq REQUEST_METHODS
      expect(page).to have_title 'Admin | Builder | Bob Sinclar'
    end

    specify 'failure' do
      login_as_account(account, 'wrong_password')
      expect(page).to have_content 'INVALID EMAIL OR PASSWORD'
      expect(page).to have_content 'Login'
    end
  end

  describe 'sign out' do
    let(:profile) { create :candidate_profile }
    let!(:account) { creat :account, profile: profilet }

    specify 'success', :js do
      login_as_account(account)

      expect(page).to have_content 'SIGNED IN SUCCESSFULLY.'

      visit '/'
      hide_welcome_screen
      find('.user-dropdown .dropdown-toggle').click
      expect(page).to have_link 'Logout'
      click_on 'Logout'

      expect(page).to have_content 'SIGNED OUT SUCCESSFULLY.'
      expect(page).to have_link 'Login'
    end
  end

  describe 'multiple accounts without subdomains' do
    let!(:account1) { create(:account) }
    let!(:account2) { create(:account) }

    it 'should create both' do
      expect(Account.count).to eq 2
    end
  end

  describe 'sign up', :js do
    let(:account) { build(:account) }
    let(:default_bg) { File.open(Rails.root.join('spec', 'fixtures', 'backgrounds', 'Farm_2.jpg')) }
    let!(:medium) { create(:medium, image: default_bg) }

    before do
      visit '/'
      click_link 'Start Building Now', match: :first
    end

    describe 'candidate' do
      before do
        click_on 'Candidate'
        expect(page).to have_link 'Terms of Service', href: front_terms_path
      end

      context 'success' do
        before { expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:user_sign_up) }
        specify 'free' do
          find('.mfp-content').click
          fill_in 'account_candidate_profile_attributes_first_name', with: 'John'
          fill_in 'account_candidate_profile_attributes_last_name',  with: 'Smith'
          fill_in 'account_candidate_profile_attributes_office',     with: 'Mayor'
          fill_in 'account_email',                                   with: account.email
          fill_in 'account_password',                                with: account.password
          fill_in 'account_password_confirmation',                   with: account.password
          click_on 'Start Building'
          click_on 'not right now'

          expect(page).to have_content 'WELCOME! YOU HAVE SIGNED UP SUCCESSFULLY.'
        end

        specify 'paid' do
          fill_in 'account_candidate_profile_attributes_first_name', with: 'John'
          fill_in 'account_candidate_profile_attributes_last_name',  with: 'Smith'
          fill_in 'account_candidate_profile_attributes_office',     with: 'Mayor'
          fill_in 'account_email',                                   with: account.email
          fill_in 'account_password',                                with: account.password
          fill_in 'account_password_confirmation',                   with: account.password
          click_on 'Start Building'
          expect(page).to have_css '.go-premium'
          find('.go-premium').click

          within '.modal-body' do
            fill_in 'Card Number', with: '4111111111111111'
            fill_in 'First Name',  with: 'John'
            fill_in 'Last Name',   with: 'Smith'
            fill_in 'Month Exp.',  with: '01'
            fill_in 'Year Exp.',   with: '2019'
            fill_in 'CVV/CVV2',    with: '123'
            fill_in 'City',        with: 'Louisiana'
            select 'CA',           from: 'State'
            fill_in 'Zip',         with: '12345'
            fill_in 'Address',     with: 'Some str.'

            click_on 'Upgrade Plan'
          end

          expect(page).to have_content 'Welcome to'
        end

        describe 'cancel premium' do
          before do
            fill_in 'account_candidate_profile_attributes_first_name', with: 'John'
            fill_in 'account_candidate_profile_attributes_last_name',  with: 'Smith'
            fill_in 'account_candidate_profile_attributes_office',     with: 'Mayor'
            fill_in 'account_email',                                   with: account.email
            fill_in 'account_password',                                with: account.password
            fill_in 'account_password_confirmation',                   with: account.password
            click_on 'Start Building'
          end

          specify 'cancel go to premium' do
            find('.go-premium').click
            find('.mfp-close').click
            expect(page).not_to have_selector('.ruckus-modal')
          end
        end
      end

      specify 'failure' do
        fill_in 'account_candidate_profile_attributes_first_name', with: 'John'
        fill_in 'account_candidate_profile_attributes_last_name',  with: 'Smith'
        fill_in 'account_candidate_profile_attributes_office',     with: 'Mayor'
        fill_in 'account_email',                                   with: account.email
        fill_in 'account_password',                                with: 'secret123'
        fill_in 'account_password_confirmation',                   with: 'bad_password'
        click_on 'Start Building'

        expect(page).to have_content "DOESN'T MATCH"
      end

      specify 'special characters' do
        fill_in 'account_candidate_profile_attributes_first_name', with: 'Иван'
        fill_in 'account_candidate_profile_attributes_last_name',  with: 'Попович'
        fill_in 'account_candidate_profile_attributes_office',     with: 'office'
        fill_in 'account_email',                                   with: 'ivan.popovich@example.com'
        fill_in 'account_password',                                with: 'secret123'
        fill_in 'account_password_confirmation',                   with: 'secret123'
        click_on 'Start Building'

        expect(page).to have_content "SHOULD NOT CONTAIN ANY SPECIAL CHARACTERS"
      end

      specify 'uniqueness failure' do
        create :account, email: 'doo@gmail.com'

        fill_in 'account_candidate_profile_attributes_first_name', with: 'John'
        fill_in 'account_candidate_profile_attributes_last_name',  with: 'Smith'
        fill_in 'account_candidate_profile_attributes_office',     with: 'Mayor'
        fill_in 'account_email',                                   with: 'doo@gmail.com'
        fill_in 'account_password',                                with: '12345678'
        fill_in 'account_password_confirmation',                   with: '12345678'
        click_on 'Start Building'

        expect(page).to have_content 'EMAIL HAS ALREADY BEEN TAKEN', count: 1
      end
    end

    describe 'organization' do
      before do
        click_on 'Organization'
        expect(page).to have_link 'Terms of Service', href: front_terms_path
      end

      context 'success' do
        specify 'free' do
          fill_in 'account_organization_profile_attributes_name', with: 'RailsMuffin'
          fill_in 'account_email',                                with: account.email
          fill_in 'account_password',                             with: account.password
          fill_in 'account_password_confirmation',                with: account.password
          click_on 'Start Building'
          click_on 'not right now'

          expect(page).to have_content 'WELCOME! YOU HAVE SIGNED UP SUCCESSFULLY.'

          visit profile_builder_path
          expect(page).to have_content 'RailsMuffin'
        end

        specify 'paid' do
          fill_in 'account_organization_profile_attributes_name', with: 'RailsMuffin'
          fill_in 'account_email',                                with: account.email
          fill_in 'account_password',                             with: account.password
          fill_in 'account_password_confirmation',                with: account.password
          click_on 'Start Building'
          expect(page).to have_css '.go-premium'
          find('.go-premium').click

          within '.modal-body' do
            fill_in 'Card Number', with: '4111111111111111'
            fill_in 'First Name',  with: 'John'
            fill_in 'Last Name',   with: 'Smith'
            fill_in 'Month Exp.',  with: '01'
            fill_in 'Year Exp.',   with: '2019'
            fill_in 'CVV/CVV2',    with: '123'
            fill_in 'City',        with: 'Louisiana'
            select 'CA',           from: 'State'
            fill_in 'Zip',         with: '12345'
            fill_in 'Address',     with: 'Some str.'

            click_on 'Upgrade Plan'
          end

          expect(page).to have_content 'Welcome to'

          visit profile_builder_path
          expect(page).to have_content 'RailsMuffin'
        end
      end

      specify 'failure' do
        fill_in 'account_organization_profile_attributes_name', with: 'RailsMuffin'
        fill_in 'account_email',                                with: account.email
        fill_in 'account_password',                             with: account.password
        fill_in 'account_password_confirmation',                with: 'bad_password'
        click_on 'Start Building'

        expect(page).to have_content "DOESN'T MATCH"
      end
    end
  end

  describe 'reload page if already signed in', :js do
    let(:profile) { create :candidate_profile }
    let(:account) { create :account, profile: profile }
    before do
      visit root_path
      login_as(account, scope: :account)
      expect(current_path).to eq root_path
    end

    after do
      expect(page).to have_content 'LOGOUT'
      expect(current_path).to eq profile_root_path
    end

    specify { click_on 'Start Building Now', match: :first }
    specify { click_on 'Login', match: :first }
  end

  describe 'sign up if user doesnt have an account', :js do
    let(:profile) { create :candidate_profile }
    let(:account) { create :account, profile: profile }

    it 'should hide login form and show sign up form' do
      visit root_path
      click_on 'Login'
      click_on "Don't have an account"

      expect(page).to have_no_css '.login-modal'
      expect(page).to have_css '.signup-modal'
    end
  end

  describe 'login into disabled account', :js do
    let!(:account) { create :account, deleted_at: 1.day.ago }

    it 'should show error' do
      login_as_account(account)
      expect(page).to have_content 'THE E-MAIL ADDRESS WITH WHICH YOU ARE TRYING TO LOGIN IS ASSOCIATED WITH A DEACTIVATED ACCOUNT. TO RE-ACTIVATE YOUR'
    end
  end

  describe 'login', :js do
    let(:profile)  { create :candidate_profile }
    let!(:account) { create :account, profile: profile }

    it 'should login' do
      login_as_account(account)
      expect(page).to have_content 'SIGNED IN SUCCESSFULLY'
      expect(current_path).to eq profile_builder_path
    end
  end

  describe 'invitation', :js do
    let!(:profile) { create(:candidate_profile) }
    let!(:account) { Account.invite!(profile_id: profile.id, email: 'someone@gmail.com') }

    before do
      profile.accounts << account
    end

    specify 'success' do
      visit root_path(invitation_token: account.raw_invitation_token)
      fill_in 'account_password', with: '11111111'
      fill_in 'account_password_confirmation', with: '11111111'
      click_on 'Set my password'

      expect(page).to have_no_content 'Start Building Now'
    end
  end
end
