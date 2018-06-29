require 'rails_helper'

describe Admin::DomainsController do
  let(:admin) { create(:admin) }

  before { sign_in(admin) }

  describe 'GET #index' do
    let!(:profile) { create :profile, :without_domain }
    let!(:account1) { create :account, profile: profile }
    let!(:account2) { create :account, profile: profile }
    let!(:ownership1) { create :ownership, account: account1, profile: profile }
    let!(:ownership2) { create :ownership, account: account2, profile: profile }
    let!(:domain1) { create :domain, profile: profile }
    let!(:domain2) { create :domain, profile: profile }

    specify do
      get :index
      expect(response).to render_template :index
      expect(assigns(:domains)).to eq [domain2, domain1]
    end
  end

  describe 'GET #show' do
    let(:domain) { create(:domain) }

    specify do
      get :show, id: domain.id
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    specify do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    let!(:profile) { create(:candidate_profile) }

    specify 'success' do
      expect {
        post :create, domain: { profile_id: profile.id, name: 'domain.com', internal: false }
      }.to change { profile.domains.count }.by(1)

      domain = profile.reload.domains.last

      expect(response).to redirect_to admin_domain_path(domain)
      expect(domain.name).to eq 'domain.com'
      expect(domain).to_not be_internal
    end

    specify 'failure' do
      expect {
        post :create, domain: { profile_id: profile.id, name: '' }
      }.to_not change { profile.domains.count }

      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    let(:domain) { create(:domain) }

    specify do
      get :edit, id: domain.id
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH #update' do
    let!(:new_profile) { create(:candidate_profile) }
    let!(:old_profile) { create(:organization_profile) }
    let(:domain) { create(:domain, profile: old_profile, name: 'domain.com', internal: false) }

    specify 'success' do
      patch :update, id:     domain.id,
                     domain: { name: 'subdomain', internal: true, profile_id: new_profile.id }

      expect(response).to redirect_to admin_domain_path(domain)
      domain.reload do |domain|
        expect(domain.profile).to eq profile
        expect(domain.name).to eq 'subdomain'
        expect(domain).to be_internal
      end
    end

    specify 'failure' do
      patch :update, id: domain.id, domain: { name: '', internal: true, profile_id: new_profile.id }

      expect(response).to render_template :edit
      domain.reload do |domain|
        expect(domain.account).to eq old_account
        expect(domain.name).to eq 'domain.com'
        expect(domain).to_not be_internal
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:domain) { create(:domain) }

    before { allow_any_instance_of(Domain).to receive(:can_destroy?).and_return(can_destroy?) }

    describe 'success' do
      let(:can_destroy?) { true }

      specify do
        expect { delete :destroy, id: domain.id }.to change(Domain, :count).by(-1)

        expect(response).to redirect_to admin_domains_path
        expect(flash[:notice]).to eq 'Domain was successfully deleted.'
      end
    end

    describe 'failure' do
      let(:can_destroy?) { false }

      specify do
        expect { delete :destroy, id: domain.id }.to_not change(Domain, :count)

        expect(response).to render_template :show
        expect(flash.now[:alert]).to eq "Can't remove this domain."
      end
    end
  end
end
