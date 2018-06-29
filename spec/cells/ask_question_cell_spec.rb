require 'rails_helper'

describe AskQuestion::Cell do
  subject { cell('ask_question/', profile: profile).call }

  let(:account) { profile.account }
  let(:profile) { create(:candidate_profile, photo: photo, questions_on: questions_on) }
  let(:photo) { nil }

  before do
    allow_any_instance_of(described_class).to receive(:enable_switcher).and_return true
  end

  describe 'show section' do
    before { allow_any_instance_of(Profile).to receive(:candidate?).and_return true }

    context 'builder' do
      before { allow_any_instance_of(Profile).to receive(:account_editing?).and_return true }
      context 'questions on' do
        let(:questions_on) { true }

        context 'photo present' do
          let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

          specify do
            is_expected.to have_css '.question-candidate'
            is_expected.to have_css '.btn-speech-bubble.btn-speech-bubble-arrow:not([disabled])'
            is_expected.to have_css '.question img[src*="image"]'
          end
        end

        context 'photo blank' do
          specify do
            is_expected.to have_css '.question-candidate'
            is_expected.to have_css '.btn-speech-bubble.btn-speech-bubble-arrow:not([disabled])'
            is_expected.to have_css '.question span.empty-image'
            is_expected.not_to have_css '.question img'
          end
        end
      end

      context 'questions off' do
        let(:questions_on) { false }

        context 'photo present' do
          let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

          specify do
            is_expected.to have_css '.question-candidate'
            is_expected.to have_css '.btn-speech-bubble.btn-speech-bubble-arrow[disabled]'
            is_expected.to have_css '.question img[src*="image"]'
          end
        end

        context 'photo blank' do
          specify do
            is_expected.to have_css '.question-candidate'
            is_expected.to have_css '.btn-speech-bubble.btn-speech-bubble-arrow[disabled]'
            is_expected.to have_css '.question span.empty-image'
            is_expected.not_to have_css '.question img'
          end
        end
      end
    end

    context 'public' do
      before { allow_any_instance_of(Profile).to receive(:account_editing?).and_return nil }

      context 'questions on' do
        let(:questions_on) { true }

        context 'photo present' do
          let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

          specify do
            is_expected.to have_css '.question-candidate'
            is_expected.to have_css '.btn-speech-bubble.btn-speech-bubble-arrow:not([disabled])'
            is_expected.to have_css '.question img[src*="image"]'
          end
        end

        context 'photo blank' do
          specify do
            is_expected.to have_css '.question-candidate'
            is_expected.to have_css '.btn-speech-bubble:not(.btn-speech-bubble-arrow)'
            is_expected.not_to have_css '.question span.empty-image'
            is_expected.not_to have_css '.question img'
          end
        end
      end

      context 'questions off' do
        let(:questions_on) { false }

        context 'photo present' do
          let(:photo) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

          specify do
            is_expected.not_to have_css '.question-candidate'
            is_expected.not_to have_css '.btn-speech-bubble'
            is_expected.not_to have_css '.question img[src*="image"]'
          end
        end

        context 'photo blank' do
          specify do
            is_expected.not_to have_css '.question-candidate'
            is_expected.not_to have_css '.btn-speech-bubble'
            is_expected.not_to have_css '.question img[src*="image"]'
            is_expected.not_to have_css '.question span.empty-image'
          end
        end
      end
    end
  end
end
