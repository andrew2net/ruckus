require 'rails_helper'

describe 'Coupons' do
  let!(:admin)     { create :admin }
  let(:expired_at) { Time.now }
  let!(:coupon)    { create :coupon, code: 'somecode', expired_at: expired_at, discount: 1.2 }

  before do
    login_as_admin(admin)
    click_on 'Coupons'
  end

  specify '#index' do
    expect(page).to have_content 'Coupons'
    expect(page).to have_selector('td', text: 'somecode')
    expect(page).to have_selector('td', text: '1.2')
  end

  specify '#new' do
    click_on 'New Coupon'
    fill_in 'coupon_code', with: ' some-new-code'

    click_on 'Create Coupon'

    expect(page).to have_selector('#coupon_code + .help-inline', text: 'invalid code')
    expect(page).to have_selector('#coupon_discount + .help-inline', text: "can't be blank")

    fill_in 'coupon_code', with: 'somenewcode'
    fill_in 'coupon_discount', with: '1.3'

    select '2020', from: 'coupon_expired_at_1i'
    select 'December', from: 'coupon_expired_at_2i'
    select '10', from: 'coupon_expired_at_3i'

    click_on 'Create Coupon'

    expect(page).to have_content('Coupon was successfully created')
    expect(page).to have_selector('td', text: 'somenewcode')
    expect(page).to have_content '2020-12-10 00:00:00 UTC'
  end

  specify '#edit' do
    click_on 'Edit'
    expect(page).to have_content('Edit Coupon')

    fill_in 'coupon_code', with: nil
    click_on 'Update Coupon'
    expect(page).to have_selector('#coupon_code + .help-inline', text: "can't be blank")

    fill_in 'coupon_code', with: 'newcode'
    click_on 'Update Coupon'

    expect(page).to have_content('Coupon was successfully updated.')
    expect(page).not_to have_selector('td', text: 'somecode')
    expect(page).to have_selector('td', text: 'newcode')
  end

  specify '#delete' do
    click_on 'Delete'

    expect(page).to have_content('Coupon was successfully destroyed.')
    expect(page).not_to have_selector('td', text: 'somecode')
  end

  specify 'send email', :js do
    click_on 'Send'
    find('.close').click
    expect(page).not_to have_selector('#sendCouponModal')

    click_on 'Send'
    within 'form' do
      click_on 'Send'
      expect(page).to have_content 'invalid email'

      fill_in 'account_email', with: 'test@gmail.com'
      find('.btn').click
    end

    expect(page).not_to have_selector('#sendCouponModal')
  end
end
