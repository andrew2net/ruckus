require 'rails_helper'

describe Profile::SocialPostsController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile}

  let(:valid_attributes) { attributes_for :social_post, provider: ['facebook'] }
  let(:invalid_attributes) { attributes_for :social_post, provider: ['invalid value'] }

  before do
    allow_any_instance_of(SocialPost).to receive(:should_post_to_facebook?).and_return true
    allow_any_instance_of(SocialPost).to receive(:submit_to_facebook)
    allow_any_instance_of(SocialPost).to receive(:remove_from_facebook)
    sign_in account
  end

  describe 'POST #create' do
    describe 'mixpanel' do
      context 'candidate' do
        specify 'local' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:campaign_update_post_local)
          post :create, { social_post: valid_attributes.merge(provider: []), format: :js }
        end

        specify 'facebook' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:campaign_update_post_facebook)
          post :create, { social_post: valid_attributes.merge(provider: ['facebook']), format: :js }
        end

        specify 'twitter' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:campaign_update_post_twitter)
          post :create, { social_post: valid_attributes.merge(provider: ['twitter']), format: :js }
        end

        specify 'all' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:campaign_update_post_all)
          post :create, { social_post: valid_attributes.merge(provider: ['facebook', 'twitter']), format: :js }
        end
      end

      context 'organization' do
        let(:profile) { create :organization_profile }

        specify 'local' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:chapter_update_post_local)
          post :create, { social_post: valid_attributes.merge(provider: []), format: :js }
        end

        specify 'facebook' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:chapter_update_post_facebook)
          post :create, { social_post: valid_attributes.merge(provider: ['facebook']), format: :js }
        end

        specify 'twitter' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:chapter_update_post_twitter)
          post :create, { social_post: valid_attributes.merge(provider: ['twitter']), format: :js }
        end

        specify 'all' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:chapter_update_post_all)
          post :create, { social_post: valid_attributes.merge(provider: ['facebook', 'twitter']), format: :js }
        end
      end
    end

    context 'with valid params' do
      it 'creates a new SocialPost' do
        expect {
          post :create, { social_post: valid_attributes, format: :js }
        }.to change(SocialPost, :count).by(1)

        expect(assigns(:social_post)).to be_a(SocialPost)
        expect(assigns(:social_post)).to be_persisted
        expect(response).to render_template 'show'
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved social_post as @social_post' do
        expect_any_instance_of(SocialPost).to receive(:deactivate_oauth_accounts!)

        # Trigger the behavior that occurs when invalid params are submitted
        post :create, { social_post: invalid_attributes, format: :js }

        expect(assigns(:social_post)).to be_a_new(SocialPost)
        expect(response).to render_template 'create'
      end
    end
  end

  describe 'GET #new' do
    context 'social posts order' do
      let!(:post1) { create :social_post, profile: profile }
      let!(:post2) { create :social_post, profile: profile }

      specify do
        expect(@controller.send(:collection)).to eq [post2, post1]
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested social_post' do
      social_post = profile.social_posts.create! valid_attributes
      expect {
        delete :destroy, { id: social_post.id, format: :js }
      }.to change(SocialPost, :count).by(-1)
      expect(response).to render_template 'destroy'
    end
  end
end
