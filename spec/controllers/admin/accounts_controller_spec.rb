require 'rails_helper'
require 'admin/accounts_controller'

describe Admin::AccountsController do
  let!(:admin)   { create :admin }
  let(:profile)  { create :candidate_profile }
  let!(:account) { create :account, profile: profile }

  describe 'permissions_tests' do
    specify 'should not allow account to enter' do
      sign_in account
      get :index

      expect(response).to redirect_to new_admin_session_path
    end

    specify 'should allow admin to enter' do
      sign_in admin
      get :index

      expect(response).to render_template :index
    end

    describe 'account sorting' do
      let!(:inactive_account) { create :account, deleted_at: Time.parse('14/08/2015 16:30') }

      specify 'show inactive' do
        get :index, only_deleted: true
        expect(@controller.send(:collection)).to eq [inactive_account]
      end

      specify 'show all by default' do
        get :index
        expect(@controller.send(:collection)).to eq [inactive_account, account]
      end

      specify 'show active by default' do
        get :index, with_deleted: false
        expect(@controller.send(:collection)).to eq [account]
      end
    end
  end

  describe 'actions_templates' do
    before { sign_in admin }

    specify 'GET #new' do
      get :new
      expect(response).to render_template :new
    end

    specify 'GET #edit' do
      get :edit, id: account.id
      expect(response).to render_template :edit
    end

    describe 'GET #show' do
      specify do
        get :show, id: account.id
        expect(response).to render_template :show
      end

      specify 'bugfix' do
        Profile.destroy_all
        get :show, id: account.id
        expect(response).to render_template :show
      end
    end

    specify 'DELETE #destroy' do
      delete :destroy, id: account.id

      expect(response).to redirect_to admin_accounts_path(superadmin: 1)
      expect(Account.count).to be_zero
    end
  end

  context 'create_account_results' do
    before { sign_in admin }
    let(:params) do
      {
        email:                 'test1_account@mail.com',
        password:              'password',
        password_confirmation: 'password'
      }
    end

    specify 'create valid account' do
      expect { post :create, account: params }.to change(Account, :count).by(1)
      expect(response).to redirect_to admin_accounts_path
    end

    specify 'create account with short password' do
      params.merge!(password: '123', password_confirmation: '123')

      expect { post :create, account: params }.to change(Account, :count).by(0)
      expect(response).to render_template :new
    end

    specify 'create account with invalid password confirmation' do
      params.merge!(password_confirmation: 'wrong_confirmation')

      expect { post :create, account: params }.to change(Account, :count).by(0)
      should render_template :new
    end

    specify 'create account with taken email' do
      params.merge!(email: account.email)

      expect { post :create, account: params }.to change(Account, :count).by(0)
      should render_template :new
    end
  end

  context 'edit_account_results' do
    before do
      @new_account = create :account, email: 'old_mail@mail.com'
      sign_in admin
    end

    specify 'edit account with valid email and without password' do
      patch :update, id: @new_account.id, account: { email: 'new_mail@mail.com' }

      expect(response).to redirect_to admin_accounts_path
      expect(@new_account.reload.email).to eq 'new_mail@mail.com'
    end

    specify 'edit account with valid email and with valid password' do
      patch :update, id: @new_account.id, account: { email:                 'new_mail@mail.com',
                                                       password:              'password',
                                                       password_confirmation: 'password' }

      expect(response).to redirect_to admin_accounts_path
      expect(@new_account.reload.email).to eq 'new_mail@mail.com'
    end

    specify 'edit account with valid email and with invalid password' do
      patch :update, id: @new_account.id, account: { email:                 'new_mail@mail.com',
                                                       password:              'password',
                                                       password_confirmation: '' }

      expect(response).to render_template :edit
      expect(@new_account.reload.email).to eq 'old_mail@mail.com'
    end

    specify 'edit account with taken email' do
      patch :update, id: @new_account.id, account: { email: account.email }

      expect(response).to render_template :edit
      expect(@new_account.reload.email).to eq 'old_mail@mail.com'
    end
  end
end
