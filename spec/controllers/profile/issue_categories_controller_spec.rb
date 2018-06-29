require 'rails_helper'

describe Profile::IssueCategoriesController do
  let(:profile)  { create :candidate_profile }
  let!(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'POST #create' do
    check_authorizing { xhr :post, :create, issue_category: attributes_for(:issue_category) }

    specify 'success' do
      expect {
        xhr :post, :create, issue_category: attributes_for(:issue_category)
      }.to change(profile.issue_categories, :count).by(1)

      expect(response).to render_template('create')
    end

    specify 'reject profile id' do
      expect {
        xhr :post, :create, issue_category: attributes_for(:issue_category).merge(profile_id: 345)
      }.to change(profile.issue_categories, :count).by(1)
    end

    specify 'failure' do
      expect {
        xhr :post, :create, issue_category: attributes_for(:issue_category, name: nil)
      }.to change(IssueCategory, :count).by(0)

      expect(response).to render_template('create')
    end
  end

  describe 'mixpanel' do
    context 'candidate' do
      specify do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:add_new_issue_topic)
        expect_any_instance_of(MixpanelTracker).to receive(:track)
        xhr :post, :create, issue_category: attributes_for(:issue_category)
      end
    end

    context 'organization' do
      let(:profile) { create :organization_profile }

      specify do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:add_new_position_topic)
        expect_any_instance_of(MixpanelTracker).to receive(:track)
        xhr :post, :create, issue_category: attributes_for(:issue_category)
      end
    end
  end
end
