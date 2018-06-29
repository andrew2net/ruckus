require 'rails_helper'

describe MediaStream::Cell do
  subject { cell('media_stream/', profile: profile).call }

  let(:account) { profile.account }
  let(:profile) { create(:candidate_profile, media_on: media_on) }
  let(:media_on) { true }

  describe 'showing media section' do
    let!(:medium) { create(:medium, profile: profile) }

    context 'account not editing' do
      before { allow_any_instance_of(Profile).to receive(:account_editing?).and_return nil }

      context 'media present' do
        before { Medium.update_positions([medium.id]) }

        describe 'media_on: true' do
          let(:media_on) { true }
          specify do
            is_expected.to have_css '#media'
            is_expected.not_to have_css '.no-content-pad'
            is_expected.not_to have_css '#media-stream-switch'
            is_expected.not_to have_css '#add-photos-to-media-stream'
          end
        end

        describe 'media_on: false' do
          let(:media_on) { false }
          specify do
            is_expected.not_to have_css '#media'
            is_expected.not_to have_css '.no-content-pad'
            is_expected.not_to have_css '#media-stream-switch'
            is_expected.not_to have_css '#add-photos-to-media-stream'
          end
        end
      end

      context 'media blank' do
        before { Medium.update_all(position: nil) }

        describe 'media_on: true' do
          let(:media_on) { true }
          specify do
            is_expected.not_to have_css '#media'
            is_expected.not_to have_css '.no-content-pad'
            is_expected.not_to have_css '#media-stream-switch'
            is_expected.not_to have_css '#add-photos-to-media-stream'
          end
        end

        describe 'media_on: false' do
          let(:media_on) { false }
          specify do
            is_expected.not_to have_css '#media'
            is_expected.not_to have_css '.no-content-pad'
            is_expected.not_to have_css '#media-stream-switch'
            is_expected.not_to have_css '#add-photos-to-media-stream'
          end
        end
      end
    end

    context 'account editing' do
      before { allow_any_instance_of(Profile).to receive(:account_editing?).and_return true }

      context 'media present' do
        before { Medium.update_positions([medium.id]) }

        describe 'media_on: true' do
          let(:media_on) { true }
          specify do
            is_expected.to have_css '#media'
            is_expected.not_to have_css '.no-content-pad'
            is_expected.to have_css '#media-stream-switch'
            is_expected.to have_css '#add-photos-to-media-stream'
          end
        end

        describe 'media_on: false' do
          let(:media_on) { false }
          specify do
            is_expected.to have_css '#media'
            is_expected.not_to have_css '.no-content-pad'
            is_expected.to have_css '#media-stream-switch'
            is_expected.to have_css '#add-photos-to-media-stream'
          end
        end
      end

      context 'media blank' do
        before { Medium.update_all(position: nil) }

        describe 'media_on: true' do
          let(:media_on) { true }
          specify do
            is_expected.not_to have_css '#media'
            is_expected.to have_css '.no-content-pad'
            is_expected.not_to have_css '#media-stream-switch'
            is_expected.to have_css '#add-photos-to-media-stream'
          end
        end

        describe 'media_on: false' do
          let(:media_on) { false }
          specify do
            is_expected.not_to have_css '#media'
            is_expected.to have_css '.no-content-pad'
            is_expected.not_to have_css '#media-stream-switch'
            is_expected.to have_css '#add-photos-to-media-stream'
          end
        end
      end
    end
  end
end
