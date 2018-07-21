require 'rails_helper'

describe 'Accounts' do
  let!(:profile1) do
    create :candidate_profile, first_name: 'First', last_name: 'Test', credit_card_holder: credit_card_holder
  end
  let!(:account)           { create :account, profile: profile1 }
  let!(:ownership)         { create :ownership, profile: profile1, account: account }
  let(:credit_card_holder) { create :credit_card_holder }

  before do
    login_as(account, scope: :account)
    visit account_profiles_path
    click_link 'Build my site'
  end

  describe 'index' do
    let!(:profile2) do
      create(:candidate_profile, :premium, account: account, first_name: ('f' * 25), last_name: ('l' * 25))
    end
    let!(:profile3) { create(:organization_profile, :free, account: account, name: 'ThirdOrg') }

    before do
      account.profiles << profile2
      account.profiles << profile3

      visit account_profiles_path
    end

    specify 'list' do
      within "#profile-#{profile1.id}" do
        expect(page).to have_selector '.domain-url', text: 'First Test'
        expect(page).to have_selector '.note', text: '- Candidate'
        expect(page).to have_no_content 'upgrade'
        expect(page).to have_content 'cancel'
        expect(page).to have_css "a[href*='#{profile1.domain.name}'] .icon-globe"
      end

      profile2_name_result = 'fffffffffffffffffffffffff llllll...'

      within "#profile-#{profile2.id}" do
        expect(page).to have_selector '.domain-url', text: profile2_name_result
        expect(page).to have_selector '.note', text: '- Candidate'
        expect(page).to have_no_content 'upgrade'
        expect(page).to have_content 'cancel'
        expect(page).to have_css "a[href*='#{profile2.domain.name}'] .icon-globe"
      end

      within "#profile-#{profile3.id}" do
        expect(page).to have_selector '.note', text: 'Currently Editing'
        expect(page).to have_selector ' .domain-url', text: 'ThirdOrg'
        expect(page).to have_selector '.note', text: '- Organization'
        expect(page).to have_content 'upgrade'
        expect(page).to have_no_content 'cancel'
        expect(page).to have_css "a[href*='#{profile3.domain.name}'] .icon-globe"
      end
    end

    specify 'edit' do
      expect(page).to have_selector "#profile-#{profile3.id} .note", text: 'Currently Editing'
      expect(page).not_to have_selector "#profile-#{profile2.id} .note", text: 'Currently Editing'

      within "#profile-#{profile2.id}" do
        click_on 'Edit'
      end

      expect(page).not_to have_selector "#profile-#{profile3.id} .note", text: 'Currently Editing'
      expect(page).to have_selector "#profile-#{profile2.id} .note", text: 'Currently Editing'
    end

    specify 'activate / unactivate', :js do
      block_id = "#profile-#{profile3.id}"

      expect(page).to have_css block_id
      expect(page).not_to have_css "#{block_id}.section-disabled"

      click_link 'Build my site'
      within block_id do
        find('.switch-builder').click
      end

      expect(page).to have_css "#{block_id}.section-disabled"
      expect(page).to have_link('Preview')

      within block_id do
        expect(find('.domain-link')['href']).to eq profile_preview_profile_path(profile3)
      end

      wait_for_ajax
      visit current_url

      expect(page).to have_css "#{block_id}.section-disabled"

      within block_id do
        find('.switch-builder').click
      end

      expect(page).to have_link('View Live Site')
      expect(page).to have_css block_id

      within block_id do
        expect(find('.domain-link')['href']).to include profile3.domain.name
      end

      wait_for_ajax
      visit current_url

      expect(page).to have_css block_id
      expect(page).to have_no_css "#{block_id}.section-disabled"
    end
  end

  describe 'create' do
    specify 'candidate' do
      click_on 'candidate'
      fill_in 'profile_first_name', with: 'John'
      fill_in 'profile_last_name', with: 'Smith'
      fill_in 'profile_office', with: 'President'

      click_on 'Submit'

      expect(page).to have_selector '.domain-url', text: 'John Smith'
    end

    specify 'organization' do
      click_on 'organization'

      fill_in 'profile_name', with: 'JohnOrg'

      click_on 'Submit'

      expect(page).to have_selector '.domain-url', text: 'JohnOrg'
    end
  end

  describe 'editors', :js do
    context 'paid account' do
      specify 'manage' do
        within "#profile-#{profile1.id} + .member-list-pad" do
          click_on 'Members List'

          expect(page).to have_content 'ADD NEW EDITOR'
          expect(page).not_to have_content 'Pending Invites'

          click_on 'Add New Editor'
          fill_in 'account_email', with: 'bad-email'
          click_on 'Add'

          expect(page).to have_content 'invalid'

          fill_in 'account_email', with: 'someone@gmail.com'
          click_on 'Add'

          expect(page).not_to have_css 'form #account_email'
          expect(page).to have_content 'Pending Invites'
          expect(page).to have_content 'EDITOR', count: 2
          expect(page).to have_content 'someone@gmail.com'

          find('.delete-member').click
          expect(page).not_to have_content 'someone@gmail.com'
          expect(page).not_to have_content 'Pending Invites'
          expect(page).to have_content 'EDITOR', count: 1
        end
      end
    end

    context 'free account' do
      let(:credit_card_holder) { nil }

      specify do
        within "#profile-#{profile1.id} + .member-list-pad" do
          click_on 'Members List'

          expect(page).not_to have_content 'ADD NEW EDITOR'
          expect(page).to have_content 'UPGRADE'
        end
      end
    end
  end

  describe 'make editor as owner', :js do
    let!(:account2) { create :account, email: 'newaccount@gmail.com' }

    before do
      profile1.accounts << account2
      account2.ownerships.update_all type: 'EditorOwnership'
    end

    specify do
      visit current_url

      within "#profile-#{profile1.id} + .member-list-pad" do
        click_on 'Members List'

        within "#account-#{account.id}" do
          expect(page).to have_content 'ADMIN'
          expect(page).not_to have_css '.glyphicon.glyphicon-pencil'
          expect(page).not_to have_content 'EDITOR'
        end

        within "#account-#{account2.id}" do
          expect(page).to have_content 'newaccount@gmail.com'
          expect(page).to have_content 'EDITOR'
        end

        # todo: fix
        # find("#account-#{account2.id} .glyphicon.glyphicon-pencil").click
        # expect(page).to have_css '.modal-body'

        # within '.modal-body' do
        #   select 'Admin', from: 'ownership_type'
        #   click_on 'Apply'
        # end

        # expect(page).not_to have_content 'APPLY'
        # click_on 'Members List'

        # within "#account-#{account2.id}" do
        #   expect(page).to have_content 'ADMIN'
        #   expect(page).to have_css '.glyphicon.glyphicon-pencil'
        # end
        # or
        # within "#account-#{account2.id}" do
        #   expect(page).to have_content 'ADMIN'
        #   expect(page).not_to have_css '.glyphicon.glyphicon-pencil'
        # end
      end
    end
  end

  describe 'upgrade builder', :js do
    let!(:coupon) { create(:coupon, code: 'somecode') }
    let(:profile_trait) { :free }
    let(:credit_card_holder) { nil }

    specify 'builder' do
      visit profile_builder_path
      find('.premium-label.upgrade').click

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

        click_on 'coupon code? Click here'
        fill_in 'Coupon code', with: 'somecode'

        click_on 'Upgrade Plan'
      end

      expect(page).not_to have_content '.premium-label.upgrade'
    end
  end

  describe 'upgrade', :js do
    let!(:profile2) { create(:candidate_profile, :free) }
    let!(:coupon) { create(:coupon, code: 'somecode') }

    before do
      account.profiles << profile2
    end

    specify 'apply correct code' do
      visit account_profiles_path

      find("#profile-#{profile2.id} .premium-label").click

       within '.modal-body' do
         expect(page).to have_content '$20'
         click_on 'coupon code? Click here'
         fill_in 'Coupon code',  with: 'somecode'
         click_on 'Apply'

         expect(page).not_to have_content '$20'
         expect(page).to have_content '$19.74'
       end
    end

    specify 'apply incorrect code' do
      visit account_profiles_path

      find("#profile-#{profile2.id} .premium-label").click

       within '.modal-body' do
         expect(page).to have_content '$20'
         click_on 'coupon code? Click here'
         fill_in 'Coupon code',  with: 'invalid-code'
         click_on 'Apply'

         expect(page).to have_content '$20'
         expect(page).not_to have_content '$19.74'

         expect(page).to have_selector('#credit_card_holder_coupon_code + .help-inline', text: 'invalid code')
       end
    end

    specify 'upgrade' do
      visit account_profiles_path
      find("#profile-#{profile2.id} .edit-link").click

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

        click_on 'coupon code? Click here'
        fill_in 'Coupon code',  with: 'somecode'

        click_on 'Upgrade Plan'
      end

      expect(page).to have_no_content 'upgrade'
      expect(page).to have_content 'premium'

      click_on 'cancel'

      within '.modal-body' do
        click_on 'cancel'
      end

      expect(page).to have_content 'upgrade'
    end
  end

  describe 'update card' do
    let!(:credit_card_holder) { create :credit_card_holder, token: '1234' }
    let!(:profile3) { create(:candidate_profile, credit_card_holder: credit_card_holder) }

    before do
      account.profiles << profile3
    end

    it 'success' do
      visit account_profiles_path
      find("#profile-#{profile3.id} .card-update-link").click

      expect do
        expect do
          within '.modal-body' do
            fill_in 'Card Number', with: '4111111111111112'
            fill_in 'Month Exp.',  with: '01'
            fill_in 'Year Exp.',   with: '2019'
            fill_in 'CVV/CVV2',    with: '123'

            click_on 'Update Card'
          end
        end.to change { profile3.credit_card_holder.credit_card.reload.last_four }
      end.to change { credit_card_holder.reload.token }
    end
  end
end
