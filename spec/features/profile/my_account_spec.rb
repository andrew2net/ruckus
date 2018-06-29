require 'rails_helper'

NEW_PASSWORD = '12345678'

describe 'Settings' do
  let(:profile)  { create :candidate_profile, address_1: 'test address' }
  let!(:account) { create :account, profile: profile }

  before do
    login_as(account, scope: :account)
    visit edit_profile_my_account_path
  end

  it "should have correct field names" do
    expect(page).to have_field('First Name')
    expect(page).to have_field('Last Name')
    expect(page).to have_field('Email Address')
    expect(page).to have_field('Phone Number')
  end

  describe 'Edit' do
    it 'should display current values' do
      expect(find_field('account_profile_attributes_first_name').value).to eq account.profile.first_name
      expect(find_field('account_profile_attributes_last_name').value).to  eq account.profile.last_name
      expect(find_field('account_email').value).to                         eq account.email
      expect(find_field('account_profile_attributes_phone').value).to     eq account.profile.phone
    end

    it 'can edit first/last name & email' do
      fill_in 'account_profile_attributes_first_name', with: 'Johny'
      fill_in 'account_profile_attributes_last_name',  with: 'Smithy'
      fill_in 'account_profile_attributes_phone',      with: '212-232-1291'
      fill_in 'account_email',                         with: 'boo@gmail.com'
      click_on 'Update'

      expect(Profile.count).to eq 1

      account.profile.reload.tap do |profile|
        expect(profile.first_name).to    eq 'Johny'
        expect(profile.last_name).to     eq 'Smithy'
        expect(profile.phone).to         eq '212-232-1291'
        expect(profile.account.email).to eq 'boo@gmail.com'
        expect(profile.address_1).to     eq 'test address'
      end
    end

    describe 'edit password' do
      let(:old_password) { account.encrypted_password }

      it 'can update when correct current password is provided' do
        fill_in 'account_password',              with: NEW_PASSWORD
        fill_in 'account_password_confirmation', with: NEW_PASSWORD
        click_on 'Update'

        expect(Profile.count).to eq 1
        expect(Profile.first.address_1).to eq 'test address'
        expect(Account.first.encrypted_password).not_to eq old_password
      end

      context 'fail' do
        after do
          expect(Profile.count).to eq 1
          expect(Account.first.encrypted_password).to eq old_password
          expect(page).to have_content "doesn't match"
        end

        it 'can not update if passwords do not match' do
          fill_in 'account_password',              with: NEW_PASSWORD
          fill_in 'account_password_confirmation', with: 'something else'
          click_on 'Update'
        end
      end
    end
  end

  describe 'deactivate account' do
    it 'should only mark account as deactivated, but not delete it' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:account_status_deactivate)
      click_on 'Deactivate Account'

      expect(current_path).to eq root_path
      account.reload.tap do |account|
        expect(account.reload).to be_present
        expect(account.reload).to be_deleted
      end
    end
  end
end
