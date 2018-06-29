require 'rails_helper'

describe Admin::IssuesController do
  let(:admin) { create :admin }
  let!(:profile) { create :candidate_profile }
  let!(:account) { create :account, profile: profile }
  let!(:issue_category) { create :issue_category, profile: profile }
  let!(:issue) do
    create :issue, profile: profile,
                   issue_category: issue_category,
                   title: 'Title'
  end



  describe 'Actions' do
    before { sign_in admin }

    specify 'GET #index' do
      get :index, account_id: account.id, profile_id: profile.id
      expect(response).to render_template :index
    end

    specify 'GET #new' do
      get :new, account_id: account.id, profile_id: profile.id
      expect(response).to render_template :new
    end

    specify 'GET #edit' do
      get :edit, account_id: account.id, id: issue.id, profile_id: profile.id
      expect(response).to render_template :edit
    end

    specify 'GET #show' do
      get :show, account_id: account.id, id: issue.id, profile_id: profile.id
      expect(response).to render_template :show
    end

    specify 'DELETE #destroy' do
      delete :destroy, id: issue.id, account_id: account.id, profile_id: profile.id

      expect(response).to redirect_to admin_account_profile_issues_path(account, profile)
      expect(profile.issues.count).to be_zero
    end

    describe 'POST #create' do
      let(:params) do
        { title: 'My Title',
          description: 'My Description',
          issue_category_id: issue_category.id }
      end

      specify 'create valid issue' do
        expect { post :create, issue: params, profile_id: profile.id, account_id: account.id }
          .to change(profile.issues, :count).by(1)
        expect(response).to redirect_to admin_account_profile_issues_path(account, profile)
      end

      specify 'create invalid issue' do
        params.merge!(title: '')

        expect { post :create, issue: params, profile_id: profile.id, account_id: account.id }
          .to change(Issue, :count).by(0)
        expect(response).to render_template :new
      end
    end

    describe 'PATCH #update' do
      specify 'update with valid params' do
        patch :update, id: issue.id, issue: { title: 'New Title' }, profile_id: profile.id, account_id: account.id

        expect(response).to redirect_to admin_account_profile_issues_path(account, profile)
        expect(issue.reload.title).to eq 'New Title'
      end

      specify 'update with invalid params' do
        patch :update, id: issue.id, issue: { title: '' }, profile_id: profile.id, account_id: account.id

        expect(response).to render_template :edit
        expect(issue.reload.title).to eq 'Title'
      end
    end
  end

  describe 'Access' do
    specify 'should not allow account to enter' do
      sign_in account
      get :index, profile_id: profile.id, account_id: account.id

      expect(response).to redirect_to new_admin_session_path
    end

    specify 'should not allow anyone to enter' do
      get :index, profile_id: profile.id, account_id: account.id

      expect(response).to redirect_to new_admin_session_path
    end
  end
end
