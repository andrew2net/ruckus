require 'rails_helper'

describe Footer::Cell do
  subject { cell('footer/', profile: profile).call }

  before do
    allow_any_instance_of(Profile).to receive(:candidate?).and_return is_candidate
    allow_any_instance_of(Profile).to receive(:account_editing?).and_return account_editing
  end

  let(:account_editing) { true }
  let(:is_candidate) { true }
  let(:paths) { Rails.application.routes.url_helpers }

  # todo: shared example
  describe 'GENERAL INFO' do
    context 'candidate' do
      let(:profile) { create :candidate_profile, first_name: 'John', last_name: 'Smith', office: 'Candidate' }

      specify do
        is_expected.to have_css '#join-campaign h4', text: 'John Smith for Candidate'
      end
    end

    context 'organization' do
      let(:profile) { create :organization_profile, name: 'Company', office: 'Candidate' }
      let(:is_candidate) { false }

      specify do
        is_expected.to have_css '#join-campaign h4', text: 'Company Candidate'
      end
    end
  end

  # Todo: maybe move to shared example
  describe 'TAGLINE' do
    let(:profile) { create :candidate_profile, tagline: tagline }
    let(:tagline) { 'some tagline' }

    context 'builder' do
      context 'tagline present' do
        context 'candidate' do
          specify { is_expected.to have_text 'some tagline' }
        end

        context 'organization' do
          let(:is_candidate) { false }

          specify { is_expected.to have_text 'some tagline' }
        end
      end

      context 'tagline blank' do
        let(:tagline) { nil }

        context 'candidate' do
          specify { is_expected.to have_text 'Tagline' }
        end

        context 'organization' do
          let(:is_candidate) { false }

          specify { is_expected.to have_text 'Tagline' }
        end
      end
    end

    context 'public' do
      let(:account_editing) { false }
      context 'tagline present' do
        context 'candidate' do
          specify { is_expected.to have_text 'some tagline' }
        end

        context 'organization' do
          let(:is_candidate) { false }

          specify { is_expected.to have_text 'some tagline' }
        end
      end

      context 'tagline blank' do
        let(:tagline) { nil }

        context 'candidate' do
          specify { is_expected.not_to have_text 'Tagline' }
        end

        context 'organization' do
          let(:is_candidate) { false }

          specify { is_expected.not_to have_text 'Tagline' }
        end
      end
    end
  end

  describe 'DISCLAIMER' do
    let(:profile) { create :candidate_profile, campaign_disclaimer: campaign_disclaimer }
    let(:campaign_disclaimer) { 'campaign disclaimer' }

    context 'disclaimer present' do
      context 'builder' do
        specify do
          is_expected.to have_text 'campaign disclaimer'
          is_expected.to have_css '.name .i-edit'
        end
      end

      context 'public' do
        let(:account_editing) { false }

        specify do
          is_expected.to have_text 'campaign disclaimer'
          is_expected.not_to have_css '.name .i-edit'
        end
      end
    end

    context 'disclaimer blank' do
      let(:campaign_disclaimer) { nil }

      context 'builder' do
        specify do
          is_expected.to have_css 'span', text: 'Disclaimer'
          is_expected.to have_css '.name .i-edit'
        end
      end

      context 'public' do
        let(:account_editing) { false }
        specify do
          is_expected.not_to have_css 'span', text: 'Disclaimer'
          is_expected.not_to have_css '.name .i-edit'
        end
      end
    end
  end

  describe 'CONTACT INFO' do
    context 'info present' do
      let(:profile) do
        create :candidate_profile, address_1: 'Address 1',
                                   address_2: 'Address 2',
                                   contact_zip: '12345',
                                   contact_city: 'City',
                                   contact_state: 'CA',
                                   phone: '123-234-3456'
      end

      context 'builder' do

        specify do
          is_expected.to have_text 'Address 1'
          is_expected.to have_text 'Address 2'
          is_expected.to have_text 'City, CA 12345'
          is_expected.to have_text '123-234-3456'
          is_expected.to have_css '#contact-info .i-edit'
        end
      end

      context 'public' do
        let(:account_editing) { false }

        specify do
          is_expected.to have_text 'Address 1'
          is_expected.to have_text 'Address 2'
          is_expected.to have_text 'City, CA 12345'
          is_expected.to have_text '123-234-3456'
          is_expected.not_to have_css '#contact-info .i-edit'
        end
      end
    end

    context 'info blank' do
      let(:profile) do
        create :candidate_profile, address_1: nil,
                                   address_2: nil,
                                   contact_zip: nil,
                                   contact_city: nil,
                                   contact_state: nil,
                                   phone: nil
      end

      context 'builder' do
        specify do
          is_expected.to have_css '.text-placeholder', text: 'Contact'
          is_expected.to have_css '#contact-info .i-edit'
        end
      end

      context 'public' do
        let(:account_editing) { false }

        specify do
          is_expected.not_to have_css '.text-placeholder', text: 'Contact'
          is_expected.not_to have_css '#contact-info .i-edit'
        end
      end
    end
  end

  describe 'JOIN US form' do
    context 'candidate' do
      let(:profile) { create :candidate_profile }
      specify { is_expected.to have_css '#social-footer #user_email' }
    end

    context 'organization' do
      let(:profile) { create :organization_profile }
      specify { is_expected.to have_css '#social-footer #user_email' }
    end
  end

  describe 'ASK QUESTION' do
    let(:profile) { create :candidate_profile }
    specify { is_expected.to have_css '.question' }
  end

  describe 'FOOTER' do
    let(:profile) { create :candidate_profile }
    specify do
      is_expected.to have_css '#footer'
      is_expected.to have_link 'Home', href: paths.root_url(subdomain: nil, host: 'test.host')
      is_expected.to have_link 'FAQ', href: paths.front_faq_path
      is_expected.to have_link 'Terms of Service/Privacy Policy', href: paths.front_terms_path
      is_expected.to have_link 'Contact Us', href: paths.front_contact_us_path
    end
  end

  describe 'SOCIAL' do
    let(:profile) { create :candidate_profile, facebook_on:  true, twitter_on:   true }
    let!(:facebook_account) { create(:oauth_account, :facebook, profile: profile) }
    let!(:twitter_account) { create(:oauth_account, :twitter, profile: profile) }

    specify do
      is_expected.to have_css '#social-footer .twitter'
      is_expected.to have_css '#social-footer .facebook'
    end
  end
end
