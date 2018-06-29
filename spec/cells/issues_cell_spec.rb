require 'rails_helper'

describe MediaStream::Cell do
  subject { cell('issues/', profile: profile).call }

  let(:account) { profile.account }
  let(:profile) { create(:candidate_profile, issues_on: issues_on) }
  let(:paths) { Rails.application.routes.url_helpers }

  let(:issues_on) { true }

  context 'builder' do
    before do
      allow_any_instance_of(Profile).to receive(:account_editing?).and_return true
      allow_any_instance_of(Profile).to receive(:candidate?).and_return true
    end

    context 'on' do
      let(:issues_on) { true }

      context 'issues present' do
        let!(:issue_category) { create :issue_category, name: 'Some Category', profile: profile }
        let!(:issue) { create :issue, profile: profile, title: 'Some Title', issue_category: issue_category }

        specify do
          is_expected.to have_css '.section#issues'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.to have_css '.issue h5', text: 'Some Title'
          is_expected.to have_link 'Some Category', href: paths.front_profile_issues_path(profile, category_id: issue_category.id)
          is_expected.to have_link 'All', href: paths.front_profile_issues_path(profile)
          is_expected.not_to have_link 'Education' # only allowed categories

          is_expected.to have_css '#issues a .i-edit' #pencil
          is_expected.to have_css '#issues .issue .no-content-pad', count: 2 # placeholders
          is_expected.to have_css '#issues .switch-builder'
        end
      end

      context 'issues do not exist' do
        specify do
          is_expected.to have_css '.section#issues'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.to have_link 'All', href: paths.front_profile_issues_path(profile)

          is_expected.to have_css '#issues a .i-edit'
          is_expected.to have_css '#issues .issue .no-content-pad', count: 3
          is_expected.to have_css '#issues .switch-builder'
        end
      end
    end

    context 'off' do
      let(:issues_on) { false }

      context 'issues present' do
        let!(:issue_category) { create :issue_category, name: 'Some Category', profile: profile }
        let!(:issue) { create :issue, profile: profile, title: 'Some Title', issue_category: issue_category }

        specify do
          is_expected.to have_css '.section#issues'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.to have_css '.issue h5', text: 'Some Title'
          is_expected.to have_link 'Some Category', href: paths.front_profile_issues_path(profile, category_id: issue_category.id)
          is_expected.to have_link 'All', href: paths.front_profile_issues_path(profile)
          is_expected.not_to have_link 'Education' # only allowed categories

          is_expected.to have_css '#issues a .i-edit' #pencil
          is_expected.to have_css '#issues .issue .no-content-pad', count: 2 # placeholders
          is_expected.to have_css '#issues .switch-builder'
        end
      end

      context 'issues do not exist' do
        specify do
          is_expected.to have_css '.section#issues'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.to have_link 'All', href: paths.front_profile_issues_path(profile)

          is_expected.to have_css '#issues a .i-edit'
          is_expected.to have_css '#issues .issue .no-content-pad', count: 3
          is_expected.to have_css '#issues .switch-builder'
        end
      end
    end
  end

  context 'public' do
    before { allow_any_instance_of(Profile).to receive(:account_editing?).and_return nil }

    context 'on' do
      let(:issues_on) { true }

      context 'issues present' do
        let!(:issue_category) { create :issue_category, name: 'Some Category', profile: profile }
        let!(:issue) { create :issue, profile: profile, title: 'Some Title', issue_category: issue_category }

        specify do
          is_expected.to have_css '.section#issues'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.to have_css '.issue h5', text: 'Some Title'
          is_expected.to have_link 'Some Category', href: paths.front_profile_issues_path(profile, category_id: issue_category.id)
          is_expected.to have_link 'All', href: paths.front_profile_issues_path(profile)

          is_expected.not_to have_css '#issues a .i-edit' #pencil
          is_expected.not_to have_css '#issues .issue .no-content-pad', count: 2 # placeholders
          is_expected.not_to have_css '#issues .switch-builder'
        end
      end

      context 'issues do not exist' do
        specify do
          is_expected.to have_css '.section:not(#issues)'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.not_to have_link 'All', href: paths.front_profile_issues_path(profile)

          is_expected.not_to have_css '#issues a .i-edit'
          is_expected.not_to have_css '#issues .issue .no-content-pad', count: 3
          is_expected.not_to have_css '#issues .switch-builder'
        end
      end
    end

    context 'off' do
      let(:issues_on) { false }

      context 'issues present' do
        let!(:issue_category) { create :issue_category, name: 'Some Category', profile: profile }
        let!(:issue) { create :issue, profile: profile, title: 'Some Title', issue_category: issue_category }

        specify do
          is_expected.to have_css '.section:not(#issues)'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.not_to have_css '.issue h5', text: 'Some Title'
          is_expected.not_to have_link 'Some Category', href: paths.front_profile_issues_path(profile, category_id: issue_category.id)
          is_expected.not_to have_link 'All', href: paths.front_profile_issues_path(profile)
          is_expected.not_to have_link 'Education' # only allowed categories

          is_expected.not_to have_css '#issues a .i-edit' #pencil
          is_expected.not_to have_css '#issues .issue .no-content-pad', count: 2 # placeholders
          is_expected.not_to have_css '#issues .switch-builder'
        end
      end

      context 'issues do not exist' do
        specify do
          is_expected.to have_css '.section:not(#issues)'
          is_expected.to have_css '#issues-tab-wrapper'
          is_expected.not_to have_link 'All', href: paths.front_profile_issues_path(profile)

          is_expected.not_to have_css '#issues a .i-edit'
          is_expected.not_to have_css '#issues .issue .no-content-pad', count: 3
          is_expected.not_to have_css '#issues .switch-builder'
        end
      end
    end
  end

  context 'category click' do
    let!(:issue_category1) { create :issue_category, name: 'Some Category', profile: profile }
    let!(:issue_category2) { create :issue_category, name: 'Other Category', profile: profile }
    let!(:issue1) { create :issue, profile: profile, title: 'Some Title 1', issue_category: issue_category1 }
    let!(:issue2) { create :issue, profile: profile, title: 'Some Title 2', issue_category: issue_category2 }

    before { allow_any_instance_of(Profile).to receive(:account_editing?).and_return true }

    context 'all' do
      subject { cell('issues/', profile: profile, category_id: :all).call }

      specify do
        is_expected.to have_text 'Some Title 1'
        is_expected.to have_text 'Some Title 2'
        is_expected.not_to have_css '#issues'
      end
    end

    context 'category' do
      subject { cell('issues/', profile: profile, category_id: issue_category1.id).call }

      specify do
        is_expected.to have_text 'Some Title 1'
        is_expected.not_to have_text 'Some Title 2'
        is_expected.not_to have_css '#issues'
      end
    end
  end
end
