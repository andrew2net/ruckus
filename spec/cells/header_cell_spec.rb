require 'rails_helper'

describe Header::Cell do
  subject { cell('header/', profile: profile).call }

  before do
    allow_any_instance_of(Profile).to receive(:account_editing?).and_return account_editing
    allow_any_instance_of(Profile).to receive(:candidate?).and_return is_candidate
  end

  let(:account_editing) { true }
  let(:is_candidate) { true }
  let(:profile_type) { :candidate_profile }

  describe 'PHOTO' do
    let(:profile) { create(profile_type, photo: photo) }
    let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

    context 'builder' do
      context 'candidate' do
        context 'photo present' do
          specify do
            is_expected.to have_css '.account-image.account-image-candidate .account-image-rounded img'
            is_expected.to have_css '.i-icon.i-photo'
            is_expected.not_to have_text 'Add Profile Image'
            is_expected.to have_css '.onboard-tip-profile-logo'
          end
        end

        context 'photo blank' do
          let(:photo) { nil }

          specify do
            is_expected.not_to have_css '.account-image.account-image-candidate'
            is_expected.to have_css '.i-icon.i-photo'
            is_expected.to have_text 'Add Profile Image'
            is_expected.not_to have_css '.onboard-tip-profile-logo'
          end
        end
      end

      context 'organization' do
        let(:profile_type) { :organization_profile }
        let(:is_candidate) { false }

        context 'photo present' do
          specify do
            is_expected.to have_css '.account-image.account-image-organization .account-image-rounded img'
            is_expected.to have_css '.i-icon.i-photo'
            is_expected.not_to have_text 'Add Organization Logo'
            is_expected.to have_css '.onboard-tip-profile-logo'
          end
        end

        context 'photo blank' do
          let(:photo) { nil }

          specify do
            is_expected.not_to have_css '.account-image.account-image-organization'
            is_expected.to have_css '.i-icon.i-photo'
            is_expected.to have_text 'Add Organization Logo'
            is_expected.not_to have_css '.onboard-tip-profile-logo'
          end
        end
      end
    end

    context 'public' do
      let(:account_editing) { false }
      context 'candidate' do
        context 'photo present' do
          specify do
            is_expected.to have_css '.account-image.account-image-candidate .account-image-rounded img'
            is_expected.not_to have_css '.i-icon.i-photo'
            is_expected.not_to have_text 'Add Profile Image'
            is_expected.not_to have_css '.onboard-tip-profile-logo'
          end
        end

        context 'photo blank' do
          let(:photo) { nil }

          specify do
            is_expected.to have_css '.account-image.account-image-candidate'
            is_expected.not_to have_css '.i-icon.i-photo'
            is_expected.not_to have_text 'Add Profile Image'
            is_expected.not_to have_css '.onboard-tip-profile-logo'
          end
        end
      end

      context 'organization' do
        let(:profile_type) { :organization_profile }
        let(:is_candidate) { false }

        context 'photo present' do
          specify do
            is_expected.to have_css '.account-image.account-image-organization .account-image-rounded img'
            is_expected.not_to have_css '.onboard-tip-profile-logo a .i-icon.i-photo'
            is_expected.not_to have_text 'Add Organization Logo'
            is_expected.not_to have_css '.onboard-tip-profile-logo'
          end
        end

        context 'photo blank' do
          let(:photo) { nil }

          specify do
            is_expected.to have_css '.account-image.account-image-organization'
            is_expected.not_to have_css '.onboard-tip-profile-logo a .i-icon.i-photo'
            is_expected.not_to have_text 'Add Organization Logo'
            is_expected.not_to have_css '.onboard-tip-profile-logo'
          end
        end
      end
    end
  end

  describe 'NAME' do
    context 'candidate' do
      let(:profile) { create :candidate_profile, first_name: 'John', last_name: 'Smith', office: 'president' }
      let(:is_candidate) { true }

      specify { is_expected.to have_text 'John Smith for president' }
    end

    context 'organization' do
      let(:profile) { create :organization_profile, name: 'Company', office: 'president' }
      let(:is_candidate) { false }

      specify { is_expected.to have_text 'Company president' }
    end
  end

  describe 'GENERAL INFO' do
    let(:profile) { create :candidate_profile, tagline: tagline }
    let(:tagline) { 'some tagline' }

    context 'builder' do
      context 'candidate' do
        context 'all info present' do
          let(:profile) do
            create :candidate_profile, party_affiliation: 'party',
                                       district: 'district',
                                       city: 'City',
                                       state: 'CA'
          end

          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.to have_text 'party'
            is_expected.to have_text 'district'
            is_expected.to have_text 'City, CA'
            is_expected.to have_css '#general-account-info i.i-edit'
          end
        end

        context 'some info present' do
          let(:profile) do
            create :candidate_profile, party_affiliation: 'party',
                                       district: nil,
                                       city: 'City',
                                       state: 'CA'
          end

          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.to have_text 'party'
            is_expected.to have_text 'City, CA'
            is_expected.to have_css '#general-account-info i.i-edit'
          end
        end

        context 'info blank' do
          let(:profile) do
            create :candidate_profile, party_affiliation: nil,
                                       district: nil,
                                       city: nil,
                                       state: nil
          end

          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.to have_text 'Party'
            is_expected.to have_text 'District'
            is_expected.to have_text 'Location'
            is_expected.to have_css '#general-account-info i.i-edit'
          end
        end
      end

      context 'organization' do
        let(:is_candidate) { false }

        context 'general info present' do
          let(:profile) do
            create :candidate_profile, party_affiliation: 'party',
                                       district: 'district',
                                       city: 'City',
                                       state: 'CA'
          end
          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.not_to have_text 'party'
            is_expected.not_to have_text 'district'
            is_expected.not_to have_text 'City, CA'
          end
        end

        context 'general info blank' do
          let(:profile) do
            create :candidate_profile, party_affiliation: nil,
                                       district: nil,
                                       city: nil,
                                       state: nil
          end

          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.not_to have_text 'Party'
            is_expected.not_to have_text 'District'
            is_expected.not_to have_text 'Location'
          end
        end
      end
    end

    context 'public' do
      let(:account_editing) { false }

      context 'candidate' do
        context 'all info present' do
          let(:profile) do
            create :candidate_profile, party_affiliation: 'party',
                                       district: 'district',
                                       city: 'City',
                                       state: 'CA'
          end

          specify do
            is_expected.to have_css '#general-account-info:not(.onboard-tip-edit-info)'
            is_expected.to have_text 'party'
            is_expected.to have_text 'district'
            is_expected.to have_text 'City, CA'
            is_expected.not_to have_css '#general-account-info i.i-edit'
          end
        end

        context 'some info present' do
          let(:profile) do
            create :candidate_profile, party_affiliation: 'party',
                                       district: nil,
                                       city: 'City',
                                       state: 'CA'
          end

          specify do
            is_expected.to have_css '#general-account-info:not(.onboard-tip-edit-info)'
            is_expected.to have_text 'party'
            is_expected.to have_text 'City, CA'
            is_expected.not_to have_css '#general-account-info i.i-edit'
          end
        end

        context 'info blank' do
          let(:profile) do
            create :candidate_profile, party_affiliation: nil,
                                       district: nil,
                                       city: nil,
                                       state: nil
          end

          specify do
            is_expected.to have_css '#general-account-info:not(.onboard-tip-edit-info)'
            is_expected.not_to have_text 'Party'
            is_expected.not_to have_text 'District'
            is_expected.not_to have_text 'Location'
            is_expected.not_to have_css '#general-account-info i.i-edit'
          end
        end
      end

      context 'organization' do
        let(:is_candidate) { false }

        context 'general info present' do
          let(:profile) do
            create :candidate_profile, party_affiliation: 'party',
                                       district: 'district',
                                       city: 'City',
                                       state: 'CA'
          end
          specify do
            is_expected.not_to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.not_to have_text 'party'
            is_expected.not_to have_text 'district'
            is_expected.not_to have_text 'City, CA'
          end
        end

        context 'general info blank' do
          let(:profile) do
            create :candidate_profile, party_affiliation: nil,
                                       district: nil,
                                       city: nil,
                                       state: nil
          end

          specify do
            is_expected.not_to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.not_to have_text 'Party'
            is_expected.not_to have_text 'District'
            is_expected.not_to have_text 'Location'
          end
        end
      end
    end
  end

  describe 'TAGLINE' do
    let(:profile) { create :candidate_profile, tagline: tagline }
    let(:tagline) { 'some tagline' }

    context 'builder' do
      context 'candidate' do
        context 'tagline present' do
          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.to have_css '#join-campaign-head', text: 'some tagline'
            is_expected.to have_css '#join-campaign-head .i-edit'
            is_expected.not_to have_css '.organization-tagline .i-edit'
          end
        end

        context 'tagline blank' do
          let(:tagline) { nil }

          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.to have_css '#join-campaign-head span', text: 'Tagline'
            is_expected.to have_css '#join-campaign-head .i-edit'
            is_expected.not_to have_css '.organization-tagline .i-edit'
          end
        end
      end

      context 'organization' do
        let(:is_candidate) { false }

        context 'tagline present' do
          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.to have_text 'some tagline'
            is_expected.to have_css '.organization-tagline .i-edit'
            is_expected.not_to have_css '#join-campaign-head', text: 'some tagline'
          end
        end

        context 'tagline blank' do
          let(:tagline) { nil }

          specify do
            is_expected.to have_css '#general-account-info.onboard-tip-edit-info'
            is_expected.to have_css 'span', text: 'Tagline'
            is_expected.to have_css '.organization-tagline .i-edit'
            is_expected.not_to have_css '#join-campaign-head', text: 'some tagline'
          end
        end
      end
    end

    context 'public' do
      let(:account_editing) { false }

      context 'candidate' do
        context 'tagline present' do
          specify do
            is_expected.to have_css '#general-account-info:not(.onboard-tip-edit-info)'
            is_expected.to have_css '#join-campaign-head', text: 'some tagline'
            is_expected.not_to have_css '#join-campaign-head .i-edit'
            is_expected.not_to have_css '.organization-tagline .i-edit'
          end
        end

        context 'tagline blank' do
          let(:tagline) { nil }

          specify do
            is_expected.to have_css '#general-account-info:not(.onboard-tip-edit-info)'
            is_expected.not_to have_css '#join-campaign-head .i-edit'
            is_expected.not_to have_css '#join-campaign-head span', text: 'Tagline'
            is_expected.not_to have_css '.organization-tagline .i-edit'
          end
        end
      end

      context 'organization' do
        let(:is_candidate) { false }
        context 'tagline present' do

          specify do
            is_expected.to have_css '#general-account-info:not(.onboard-tip-edit-info)'
            is_expected.to have_text 'some tagline'
            is_expected.not_to have_css '.organization-tagline .i-edit'
            is_expected.not_to have_css '#join-campaign-head .i-edit'
            is_expected.not_to have_css '#join-campaign-head', text: 'some tagline'
          end
        end

        context 'tagline blank' do
          let(:tagline) { nil }

          specify do
            is_expected.to have_css '#general-account-info:not(.onboard-tip-edit-info)'
            is_expected.not_to have_css 'span', text: 'Tagline'
            is_expected.not_to have_css '#join-campaign-head .i-edit'
            is_expected.not_to have_css '.organization-tagline .i-edit'
            is_expected.not_to have_css '#join-campaign-head', text: 'some tagline'
          end
        end
      end
    end
  end

  describe 'DONATION' do
    let(:profile) { create :candidate_profile, donations_on: true }
    let(:paths) { Rails.application.routes.url_helpers }

    context 'builder' do
      context 'DE set up' do
        let!(:de_account) { create :de_account, profile: profile, is_active_on_de: true }

        specify do
          is_expected.to have_link '$', href: paths.profile_builder_payment_account_path
          is_expected.not_to have_link 'Donate'
        end
      end

      context 'DE not set up' do
        specify do
          is_expected.to have_link '$', href: paths.new_profile_de_account_path
          is_expected.not_to have_link 'Donate'
        end
      end
    end

    context 'public' do
      let(:account_editing) { false }

      context 'DE set up' do
        let!(:de_account) { create :de_account, profile: profile, is_active_on_de: true }

        specify do
          is_expected.not_to have_link '$'
          is_expected.to have_link 'Donate'
        end
      end

      context 'DE not set up' do
        specify do
          is_expected.not_to have_link '$'
          is_expected.not_to have_link 'Donate'
        end
      end
    end
  end

  describe 'SOCIAL POSTS' do
    context 'candidate with photo' do
      let(:profile) { create :candidate_profile, photo: photo }
      let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

      context 'builder' do
        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.to have_css '#social-feed'
            is_expected.not_to have_css '.social-feed-meta-shift'
            is_expected.not_to have_css 'span.empty-image'
          end
        end

        context 'no social post' do

          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end

      context 'public' do
        let(:account_editing) { false }

        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.not_to have_css '.social-feed-meta-shift'
            is_expected.not_to have_css 'span.empty-image'
          end
        end

        context 'no social post' do
          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end
    end

    context 'candidate without photo' do
      let(:profile) { create :candidate_profile }

      context 'builder' do
        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.to have_css '#social-feed'
            is_expected.not_to have_css '.social-feed-meta-shift'
            is_expected.to have_css 'span.empty-image'
          end
        end

        context 'no social post' do
          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end

      context 'public' do
        let(:account_editing) { false }

        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.to have_css '.social-feed-meta-shift'
            is_expected.not_to have_css 'span.empty-image'
          end
        end

        context 'no social post' do
          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end
    end

    context 'organization with photo' do
      let(:profile) { create :organization_profile, photo: photo }
      let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }
      let(:is_candidate) { false }

      context 'builder' do
        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.to have_css '#social-feed'
            is_expected.to have_css '.social-feed-meta-shift'
            is_expected.not_to have_css 'span.empty-image'
          end
        end

        context 'no social post' do
          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end

      context 'public' do
        let(:account_editing) { false }

        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.to have_css '.social-feed-meta-shift'
            is_expected.not_to have_css 'span.empty-image'
          end
        end

        context 'no social post' do
          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end
    end

    context 'organization without photo' do
      let(:profile) { create :organization_profile }
      let(:is_candidate) { false }

      context 'builder' do
        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.to have_css '#social-feed'
            is_expected.to have_css '.social-feed-meta-shift'
            is_expected.not_to have_css 'span.empty-image'
          end
        end

        context 'no social post' do

          specify do
            is_expected.to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end

      context 'public' do
        let(:account_editing) { false }

        context 'social post present' do
          let!(:post) { create :social_post, profile: profile }

          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.to have_css '.social-feed-meta-shift'
            is_expected.not_to have_css 'span.empty-image'
          end
        end

        context 'no social post' do
          specify do
            is_expected.not_to have_css '.i-icon.i-social'
            is_expected.not_to have_css '#social-feed'
            is_expected.not_to have_css 'span.empty-image'
          end
        end
      end
    end
  end

  describe 'BACKGROUND' do
    let(:profile) { create :candidate_profile, background_image: image  }
    let(:image) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

    context 'builder' do
      specify do
        background_slider_css = "#header-bg #header-bg-slider.carousel.slide .carousel-inner .item.active[style='background-image:url(#{profile.background_image_url})']"
        is_expected.to have_css background_slider_css
        is_expected.to have_css '.edit-account-background .i-icon.i-photo'
      end
    end

    context 'public' do
      let(:account_editing) { false }

      specify do
        is_expected.to have_css "#header-bg[style='background-image:url(#{profile.background_image_url})']"
        is_expected.not_to have_css '.edit-account-background .i-icon.i-photo'
      end
    end
  end

  describe 'JOIN CAMPAIGN' do
    let(:profile) { create :candidate_profile }

    specify do
      is_expected.to have_css 'form#new_user'
    end
  end
end
