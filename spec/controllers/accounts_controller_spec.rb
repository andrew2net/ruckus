require 'rails_helper'

describe AccountsController do
  describe 'GET #show' do
    describe 'suspended' do
      let(:domain)           { create :domain, name: request.host, internal: false }
      let!(:internal_domain) { create :domain, name: 'internal', internal: true, profile: profile }
      let(:profile)          { create :candidate_profile, domain: domain, suspended: suspended?, premium_by_default: true }
      let!(:account)         { create :account, profile: profile }

      before do
        allow_any_instance_of(AccountsController).to receive(:show_preview_page_for?).and_return false
        with_subdomain(profile.domain.name)
      end

      context 'yes' do
        let(:suspended?) { true }

        specify do
          get :show
          expect(response).to redirect_to 'http://internal.example.com/'
        end
      end

      context 'no' do
        let(:suspended?) { false }

        specify do
          expect { get :show }.to raise_error(ActionController::RoutingError)
        end
      end
    end

    describe 'with updaid external domain' do
      let(:domain) { create(:domain, name: request.host, internal: false) }
      let(:profile) { create(:candidate_profile, domain: domain) }

      specify do
        expect { get :show }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'active / inactive' do
      let(:profile)    { create :candidate_profile, active: active?, premium_by_default: true }
      let!(:account)   { create :account, profile: profile }
      let!(:ownership) { create :ownership, account: account, profile: profile }

      context 'active' do
        let(:active?) { true }
        before { with_subdomain(profile.domain.name) }

        specify do
          get :show
          expect(response).to render_template 'show'
        end
      end

      context 'two domains active' do
        let!(:profile2)   { create :candidate_profile, active: active?, premium_by_default: true}
        let!(:account2)   { create :account, profile: profile2 }
        let!(:ownership2) { create :ownership, account: account2, profile: profile2 }
        let(:active?)     { true }

        specify 'first domain' do
          with_subdomain(profile.domain.name)

          get :show
          expect(response).to render_template 'show'
        end

        specify 'second domain' do
          with_subdomain(profile2.domain.name)

          get :show
          expect(response).to render_template 'show'
        end
      end

      context 'inactive' do
        let(:active?) { false }
        before { with_subdomain(profile.domain.name) }

        specify do
          expect { get :show }.to raise_error ActionController::RoutingError
        end
      end
    end

    describe 'success' do
      context 'standard' do
        let!(:account)   { create :account, profile: profile }
        let!(:profile)   { create :candidate_profile, premium_by_default: true }
        let!(:ownership) { create :ownership, account: account, profile: profile }

        before do
          with_subdomain(profile.domain.name)
        end

        specify do
          get :show

          expect(assigns(:account)).to eq account
          expect(assigns(:profile)).to eq profile

          expect(response).to render_template 'show'
        end

        describe 'visits counter' do
          it 'should record each visit' do
            get :show

            expect(profile.domain.visits.first.data).to eq ''
          end
        end
      end
    end

    describe 'failure' do
      context 'with wrong subdomain' do
        let(:account) { create :account, profile: profile }
        let(:profile) { create :candidate_profile }

        before { with_subdomain(profile.domain.name + '2') }

        specify do
          expect { get :show }.to raise_error(ActionController::RoutingError)
        end
      end

      context 'with deleted account' do
        let!(:account) { create :account, deleted_at: Time.now, profile: profile }
        let!(:profile) { create :candidate_profile }

        before { with_subdomain(profile.domain.name) }

        specify do
          expect { get :show }.to raise_error ActionController::RoutingError
        end
      end
    end
  end
end
