require 'rails_helper'

describe Profile::DomainsController, :cancan do
  let!(:profile) { create(:candidate_profile) }
  let(:account)  { create :account, profile: profile }
  let!(:domain)  { create :domain, profile: profile }

  before { sign_in account }

  describe 'GET index' do
    check_authorizing { get :index }

    specify 'autorized' do
      @ability.can :read, Domain
      get :index

      expect(response).to render_template :index
    end

    specify 'unauthorized' do
      @ability.cannot :read, Domain

      get :index
      expect(response).to redirect_to profile_root_path
    end
  end

  describe 'GET show' do
    check_authorizing { get :show, id: domain.id }

    specify do
      @ability.can :read, domain
      xhr :get, :show, id: domain.id

      expect(response).to render_template :show
    end

    specify 'unauthorized' do
      @ability.cannot :read, domain
      xhr :get, :show, id: domain.id

      expect(response).to redirect_to profile_root_path
    end
  end

  describe 'POST create' do
    check_authorizing { post :create, domain: attributes_for(:domain, name: 'new-domain.com') }

    describe 'authorized' do
      before { @ability.can :create, Domain }

      specify 'success' do
        expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:url_create)

        expect {
          xhr :post, :create, domain: attributes_for(:domain, name: 'new-domain.com')
        }.to change(Domain, :count).by (1)

        expect(response).to render_template :new
      end

      specify 'failure' do
        expect {
          xhr :post, :create, domain: attributes_for(:domain, name: 'w r o n g - d o m a i n')
        }.to change(Domain, :count).by (0)

        expect(response).to render_template :new
      end
    end

    specify 'unauthorized' do
      @ability.cannot :create, Domain
      post :create, domain: attributes_for(:domain, name: 'new-domain.com')

      expect(response).to redirect_to profile_root_path
    end
  end

  describe 'PATCH update' do
    check_authorizing { patch :update, id: domain.id, domain: { name: 'new-name.com' } }

    describe 'authorized' do
      before { @ability.can :update, domain }

      specify 'success' do
        expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:url_update)
        xhr :patch, :update, id: domain.id, domain: { name: 'new-name.com' }

        expect(domain.reload.name).to eq 'new-name.com'
        expect(response).to render_template :show
      end

      specify 'failure' do
        xhr :patch, :update, id: domain.id, domain: { name: 'invalid test' }

        expect(response).to render_template :edit
      end
    end

    specify 'unauthorized' do
      @ability.cannot :update, domain
      xhr :patch, :update, id: domain.id, domain: { name: 'new-name.com' }

      expect(response).to redirect_to profile_root_path
    end
  end

  describe 'DELETE destroy' do
    check_authorizing { xhr :delete, :destroy, id: domain.id }

    specify 'authorized' do
      @ability.can :destroy, domain
      allow_any_instance_of(Domain).to receive(:can_destroy?).and_return(true)
      expect { xhr :delete, :destroy, id: domain.id }.to change(Domain, :count).by(-1)
    end

    specify 'unauthorized' do
      @ability.cannot :delete, domain

      expect { xhr :delete, :destroy, id: domain.id }.to change(Domain, :count).by(0)
      expect(response).to redirect_to profile_root_path
    end
  end
end
