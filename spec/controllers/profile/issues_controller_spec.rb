require 'rails_helper'

describe Profile::IssuesController do
  let(:profile)         { create :candidate_profile }
  let!(:account)        { create :account, profile: profile }
  let!(:issue_category) { create :issue_category, profile: profile }
  let!(:issue)          { create :issue, profile: profile, issue_category: issue_category }
  let!(:valid_issue_attributes) do
    {
      title:             'Title',
      description:       'Description',
      issue_category_id: issue_category.id
    }
  end

  before { sign_in account }

  describe 'GET #new' do
    check_authorizing { get :new }

    specify 'opening the modal' do
      get :new
      expect(response).to render_template :new
    end

    specify 'loading form into opened modal' do
      xhr :get, :new
      expect(response).to render_template :new
    end
  end

  describe 'GET #index' do
    check_authorizing { get :index }

    specify 'opening the modal' do
      get :index
      expect(response).to render_template :index
    end

    specify 'loading list into opened modal' do
      xhr :get, :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #edit' do
    check_authorizing { get :edit, id: issue.id }

    specify 'opening the modal' do
      get :edit, id: issue.id
      expect(response).to render_template 'edit'
    end

    specify 'loading form into opened modal' do
      xhr :get, :edit, id: issue.id
      expect(response).to render_template 'edit'
    end

    specify 'assigning issue' do
      get :edit, id: issue.id
      expect(assigns(:issue)).to eq issue
    end
  end

  describe 'POST #create' do
    check_authorizing { post :create, issue: valid_issue_attributes, format: :js }

    specify 'success' do
      expect { post :create, issue: valid_issue_attributes, format: :js }
        .to change(profile.issues, :count).by 1

      expect(response).to render_template :show
    end

    specify 'reject profile params' do
      expect { post :create, issue: valid_issue_attributes.merge(profile_id: 234), format: :js }
        .to change(profile.issues, :count).by 1
    end

    specify 'failure' do
      expect { post :create, issue: valid_issue_attributes.merge(title: ''), format: :js }
        .to change(profile.issues, :count).by 0

      expect(response).to render_template :create
    end

    describe 'mixpanel' do
      context 'candidate' do
        specify do
          expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:add_new_issue, { issue_name: 'Title' })
          post :create, issue: valid_issue_attributes, format: :js
        end
      end

      context 'organization' do
        let(:profile) { create :organization_profile }

        specify do
          expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:add_new_position, { position_name: 'Title' })
          post :create, issue: valid_issue_attributes, format: :js
        end
      end
    end
  end

  describe 'PATCH #update' do
    let!(:issue2) { create :issue, profile: profile, issue_category: issue_category }

    check_authorizing { patch :update, id: issue.id }

    specify 'success' do
      Issue.update_positions([issue2.id, issue.id])

      expect do
        patch :update, id: issue.id,
                       issue: valid_issue_attributes.merge(title: 'New title'),
                       format: :js
      end.to change(profile.issues, :count).by 0

      expect(response).to render_template :show
      expect(issue.reload.title).to eq 'New title'
    end

    specify 'failure' do
      expect do
        patch :update, id: issue.id, issue: valid_issue_attributes.merge(title: ''), format: :js
      end.to change(profile.issues, :count).by 0

      expect(response).to render_template :update
    end

    describe 'mixpanel' do
      context 'candidate' do
        specify do
          expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:issue_update, { issue_name: 'New title' })

          patch :update, id: issue.id,
                         issue: valid_issue_attributes.merge(title: 'New title'),
                         format: :js
        end
      end

      context 'organization' do
        let(:profile) { create :organization_profile }

        specify do
          expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:position_update, { position_name: 'New title' })

          patch :update, id: issue.id,
                         issue: valid_issue_attributes.merge(title: 'New title'),
                         format: :js
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    check_authorizing { delete :destroy, id: issue.id, format: :js }

    specify do
      expect do
        delete :destroy, id: issue.id, format: :js
      end.to change(profile.issues, :count).by(-1)

      expect(response).to render_template 'destroy'
    end
  end

  describe 'POST #sort' do
    let(:issue2) { create(:issue, position: 3) }
    let(:issue3) { create(:issue, position: 1) }

    check_authorizing { post :sort, ids: [issue.id.to_s, issue2.id.to_s, issue3.id.to_s], format: :js }

    it 'should sort issues' do
      post :sort, ids: [issue.id.to_s, issue2.id.to_s, issue3.id.to_s], format: :js
      expect(response).to render_template :sort
    end
  end
end
