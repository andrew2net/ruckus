require 'rails_helper'

describe BioFeatured::Cell do
  subject { cell('bio_featured/', profile: profile).call }

  let(:account) { profile.account }
  let(:profile) do
    create :candidate_profile, biography: bio,
                               hero_unit_medium: hero_unit,
                               biography_on: bio_on,
                               hero_unit_on: hero_on
  end

  let(:bio) { nil }
  let(:hero_unit) { nil }
  let(:bio_on) { true }
  let(:hero_on) { true }

  before do
    allow_any_instance_of(Profile).to receive(:account_editing?).and_return account_editing
  end

  let(:account_editing) { nil }

  describe 'blocks' do
    context 'bio on, hero on' do
      context 'builder' do
        let(:account_editing) { true }

        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end

      context 'public' do
        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-12'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end
    end

    context 'bio off, hero on' do
      let(:bio_on) { false }

      context 'builder' do
        let(:account_editing) { true }

        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end

      context 'public' do
        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video.col-sm-8.col-sm-offset-2 img'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end
    end

    context 'bio on, hero off' do
      let(:hero_on) { false }

      context 'builder' do
        let(:account_editing) { true }

        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end

      context 'public' do
        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-12'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video img'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-12'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video img'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end
    end

    context 'bio off, hero off' do
      let(:bio_on) { false }
      let(:hero_on) { false }

      context 'builder' do
        let(:account_editing) { true }

        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.to have_css '#biography-switch.switch-builder'
            is_expected.to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.to have_css '#about-video img'
            is_expected.to have_css '#about-video-switch.switch-builder'
            is_expected.to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper.section-editable.tab-wrapper.col-sm-5.col-sm-pull-6'
            is_expected.to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end

      context 'public' do
        context 'bio present, hero present' do
          let!(:bio) { 'some long bio' }
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio present, hero blank' do
          let!(:bio) { 'some long bio' }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_text 'some long bio'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero present' do
          let!(:hero_unit) { create :medium }

          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end

        context 'bio blank, hero blank' do
          specify do
            is_expected.not_to have_css '#about-tab-wrapper'
            is_expected.not_to have_css 'i.i-edit.onboard-tip-add-bio'
            is_expected.not_to have_css '#biography-switch.switch-builder'
            is_expected.not_to have_css  '.col-sm-6.col-sm-pull-6.no-content .i-biography'

            is_expected.not_to have_css '#about-video'
            is_expected.not_to have_css '#about-video-switch.switch-builder'
            is_expected.not_to have_css '.i-icon.i-photo#add-photos-to-hero-unit-choice'
            is_expected.not_to have_css '.no-content-pad span#add-photos-to-hero-unit-choice', text: 'Add Featured Image Or Video'
          end
        end
      end
    end
  end
end
