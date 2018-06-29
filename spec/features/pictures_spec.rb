require 'rails_helper'

describe 'Pictures' do
  describe 'Organization Builder' do
    let!(:profile) { create(:organization_profile, questions_on: true, premium_by_default: true) }
    let!(:account) { create :account, profile: profile }
    let!(:social_post) { create :social_post, profile: profile }
    let(:photo) { create(:medium, profile: profile) }

    before { login_as(account, scope: :account) }

    context 'image blank' do
      before { visit profile_builder_path }
      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="fallback"]'
        end
      end

      specify 'ask question button' do
        within '.question.question-organization' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="fallback"]'
        end
      end
    end

    context 'image present' do
      before do
        account.profile.update(photo: photo.image)
        visit profile_builder_path
      end

      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="image1"]'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="image1"]'
        end
      end
    end
  end

  describe 'Organization Live' do
    let!(:profile) { create(:organization_profile, questions_on: true, premium_by_default: true) }
    let!(:account) { create :account, profile: profile }
    let!(:social_post) { create :social_post, profile: profile }
    let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'photo.jpg')) }
    let!(:ownership) { create :ownership, profile: profile, account: account }

    before { login_as(account, scope: :account) }

    context 'image blank' do
      before { visit with_subdomain(profile.domain.name) }

      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'ask question button' do
        within '.question.question-organization' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img'
        end
      end
    end

    context 'image present' do
      before do
        profile.update(photo: photo)
        visit with_subdomain(profile.domain.name)
      end

      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="photo"]'
        end
      end

      specify 'ask question button' do
        within '.question.question-organization' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="photo"]'
        end
      end
    end
  end

  describe 'Candidate Builder' do
    let!(:profile)     { create :candidate_profile, questions_on: true }
    let!(:account)     { create :account, profile: profile }
    let!(:social_post) { create :social_post, profile: profile }
    let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'photo.jpg')) }

    before { login_as(account, scope: :account) }

    context 'image blank' do
      before { visit profile_builder_path }

      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img'
        end
      end

      specify 'ask question button' do
        within '.question.question-candidate' do
          expect(page).to have_no_css 'img'
          expect(page).to have_css '.empty-image'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img'
        end
      end
    end

    context 'image present' do
      before do
        profile.update(photo: photo)
        visit profile_builder_path
      end

      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_css 'img[src*="photo"]'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="photo"]'
        end
      end

      specify 'ask question button' do
        within '.question.question-candidate' do
          expect(page).to have_css 'img[src*="photo"]'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="photo"]'
        end
      end
    end
  end

  describe 'Candidate Live' do
    let!(:profile)     { create :candidate_profile, questions_on: true, premium_by_default: true }
    let!(:account)     { create :account, profile: profile }
    let!(:ownership)   { create :ownership, profile: profile, account: account }
    let!(:social_post) { create :social_post, profile: profile }
    let(:photo)        { create(:medium, profile: profile) }

    before { login_as(account, scope: :account) }

    context 'image blank' do
      before { visit with_subdomain(profile.domain.name) }
      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'ask question button' do
        within '.question.question-candidate' do
          expect(page).to have_no_css 'img'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img'
        end
      end
    end

    context 'image present' do
      before do
        profile.update(photo: photo.image)
        visit with_subdomain(profile.domain.name)
      end

      specify 'post section' do
        within '#social-feed' do
          expect(page).to have_css 'img[src*="image1"]'
        end
      end

      specify 'post modal' do
        find("a[href='#{front_profile_social_posts_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="image1"]'
        end
      end

      specify 'ask question button' do
        within '.question.question-candidate' do
          expect(page).to have_css 'img[src*="image1"]'
        end
      end

      specify 'ask question modal' do
        find("a[href='#{new_front_profile_question_path(profile)}']").click

        within '.ruckus-modal-head-content .account-meta' do
          expect(page).to have_css 'img[src*="image1"]'
        end
      end
    end
  end
end
