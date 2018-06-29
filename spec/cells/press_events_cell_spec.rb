require 'rails_helper'

describe PressEvents::Cell do
  subject { cell('press_events/', profile: profile).call }

  let(:account) { profile.account }
  let(:profile) { create(:candidate_profile, press_on: press_on, events_on: events_on, premium_by_default: true) }
  let(:events_on) { true }
  let(:press_on) { true }

  before { allow_any_instance_of(Profile).to receive(:account_editing?).and_return account_editing }
  let(:account_editing) { nil }

  describe 'blocks' do
    context 'events on, press on' do
      context 'builder' do
        let(:account_editing) { true }

        after do
          is_expected.to have_css '#press-events.section:not(.press-only)'
          is_expected.to have_css '#press-events.section:not(.events-only)'

          is_expected.to have_css '#events.section-editable.col-sm-6'
          is_expected.to have_css '#press.section-editable.col-sm-6'

          is_expected.to have_css '#press .edit-section .i-edit'
          is_expected.to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 2
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 2

            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          before do
            5.times { create :event, profile: profile }
            5.times { create :press_release, profile: profile }
          end

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.to have_css '#events a', text: 'View All'
            is_expected.to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#events .no-content-pad span'
            is_expected.not_to have_css '#press .no-content-pad span'

            is_expected.to have_css 'li.event', count: 2
            is_expected.to have_css 'li.press', count: 2
          end
        end
      end

      context 'public' do
        after do
          is_expected.not_to have_css '#press .switch-builder'
          is_expected.not_to have_css '#events .switch-builder'

          is_expected.not_to have_css '.no-content-pad span'

          is_expected.not_to have_css '#press .edit-section .i-edit'
          is_expected.not_to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'
            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.to have_css '#press'

            is_expected.to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.to have_css '#events'
            is_expected.to have_css '#press'

            is_expected.to have_css "#press-release-#{press.id}"
            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          let!(:event1) { create :event, start_time: 7.minutes.from_now, profile: profile }
          let!(:event2) { create :event, start_time: 5.minutes.from_now, profile: profile }
          let!(:event3) { create :event, start_time: 10.minutes.from_now, profile: profile }
          let!(:event4) { create :event, start_time: 15.minutes.from_now, profile: profile }
          let!(:event5) { create :event, start_time: 20.minutes.from_now, profile: profile }

          let!(:press1) { create :press_release, profile: profile }
          let!(:press2) { create :press_release, profile: profile }
          let!(:press3) { create :press_release, profile: profile }
          let!(:press4) { create :press_release, profile: profile }
          let!(:press5) { create :press_release, profile: profile }

          before do
            PressRelease.update_positions [press2.id, press1.id, press3.id, press4.id, press5.id]
          end

          specify do
            is_expected.to have_css '#events a', text: 'View All'
            is_expected.to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.to have_css '#events'
            is_expected.to have_css '#press'

            is_expected.to have_css 'li.event', count: 2
            is_expected.to have_css 'li.press', count: 2

            is_expected.to have_css "#event-preview-#{event2.id} + #event-preview-#{event1.id}"
            is_expected.to have_css "#press-release-#{press2.id} + #press-release-#{press1.id}"

            is_expected.to have_css "#press-release-#{press2.id}.featured"
            is_expected.to have_css "#press-release-#{press1.id}.without_thumbnail:not(.featured)"
          end
        end
      end
    end

    context 'events on, press off' do
      let(:press_on) { false }

      context 'builder' do
        let(:account_editing) { true }

        after do
          is_expected.to have_css '#press-events.section:not(.press-only)'
          is_expected.to have_css '#press-events.section:not(.events-only)'

          is_expected.to have_css '#events.section-editable.col-sm-6'
          is_expected.to have_css '#press.section-editable.col-sm-6'

          is_expected.to have_css '#press .edit-section .i-edit'
          is_expected.to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 2
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 2

            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          before do
            5.times { create :event, profile: profile }
            5.times { create :press_release, profile: profile }
          end

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.to have_css '#events a', text: 'View All'
            is_expected.to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#events .no-content-pad span'
            is_expected.not_to have_css '#press .no-content-pad span'

            is_expected.to have_css 'li.event', count: 2
            is_expected.to have_css 'li.press', count: 2
          end
        end
      end

      context 'public' do
        after do
          is_expected.not_to have_css '#press .switch-builder'
          is_expected.not_to have_css '#events .switch-builder'

          is_expected.not_to have_css '.no-content-pad span'

          is_expected.not_to have_css '#press .edit-section .i-edit'
          is_expected.not_to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'
            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.not_to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.not_to have_css "#press-release-#{press.id}"
            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          before do
            5.times { create :event, profile: profile }
            5.times { create :press_release, profile: profile }
          end

          specify do
            is_expected.to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.to have_css 'li.event', count: 2
            is_expected.not_to have_css 'li.press'
          end
        end
      end
    end

    context 'events off, press on' do
      let(:events_on) { false }
      context 'builder' do
        let(:account_editing) { true }

        after do
          is_expected.to have_css '#press-events.section:not(.press-only)'
          is_expected.to have_css '#press-events.section:not(.events-only)'

          is_expected.to have_css '#events.section-editable.col-sm-6'
          is_expected.to have_css '#press.section-editable.col-sm-6'

          is_expected.to have_css '#press .edit-section .i-edit'
          is_expected.to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 2
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 2

            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          before do
            5.times { create :event, profile: profile }
            5.times { create :press_release, profile: profile }
          end

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.to have_css '#events a', text: 'View All'
            is_expected.to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#events .no-content-pad span'
            is_expected.not_to have_css '#press .no-content-pad span'

            is_expected.to have_css 'li.event', count: 2
            is_expected.to have_css 'li.press', count: 2
          end
        end
      end

      context 'public' do
        after do
          is_expected.not_to have_css '#press .switch-builder'
          is_expected.not_to have_css '#events .switch-builder'

          is_expected.not_to have_css '.no-content-pad span'

          is_expected.not_to have_css '#press .edit-section .i-edit'
          is_expected.not_to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'
            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.to have_css '#press'

            is_expected.to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.not_to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.to have_css '#press'

            is_expected.to have_css "#press-release-#{press.id}"
            is_expected.not_to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          before do
            5.times { create :event, profile: profile }
            5.times { create :press_release, profile: profile }
          end

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.to have_css '#press a', text: 'View All'

            is_expected.to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.to have_css '#press'

            is_expected.not_to have_css 'li.event'
            is_expected.to have_css 'li.press', count: 2
          end
        end
      end
    end

    context 'events off, press off' do
      let(:events_on) { false }
      let(:press_on) { false }
      context 'builder' do
        let(:account_editing) { true }

        after do
          is_expected.to have_css '#press-events.section:not(.press-only)'
          is_expected.to have_css '#press-events.section:not(.events-only)'

          is_expected.to have_css '#events.section-editable.col-sm-6'
          is_expected.to have_css '#press.section-editable.col-sm-6'

          is_expected.to have_css '#press .edit-section .i-edit'
          is_expected.to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 2
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.not_to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 2
            is_expected.to have_css '#press .no-content-pad', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 2

            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.to have_css '#events .no-content-pad span', text: 'Add New Event', count: 1
            is_expected.to have_css '#press .no-content-pad span', text: 'Add New Press Link', count: 1

            is_expected.to have_css "#press-release-#{press.id}"
            is_expected.to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          before do
            5.times { create :event, profile: profile }
            5.times { create :press_release, profile: profile }
          end

          specify do
            is_expected.to have_css '#press .switch-builder'
            is_expected.to have_css '#events .switch-builder'

            is_expected.to have_css '#events a', text: 'View All'
            is_expected.to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#events .no-content-pad span'
            is_expected.not_to have_css '#press .no-content-pad span'

            is_expected.to have_css 'li.event', count: 2
            is_expected.to have_css 'li.press', count: 2
          end
        end
      end

      context 'public' do
        after do
          is_expected.not_to have_css '#press .switch-builder'
          is_expected.not_to have_css '#events .switch-builder'

          is_expected.not_to have_css '.no-content-pad span'

          is_expected.not_to have_css '#press .edit-section .i-edit'
          is_expected.not_to have_css '#events .edit-section .i-edit'
        end

        context 'no events, no press' do
          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'
            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'
          end
        end

        context 'no events, press' do
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.not_to have_css "#press-release-#{press.id}"
          end
        end

        context 'events, no press' do
          let!(:event) { create :event, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.not_to have_css "#event-preview-#{event.id}"
          end
        end

        context 'events, press' do
          let!(:event) { create :event, profile: profile }
          let!(:press) { create :press_release, profile: profile }

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.not_to have_css "#press-release-#{press.id}"
            is_expected.not_to have_css "#event-preview-#{event.id}"
          end
        end

        context 'lots of events, lots of press' do
          before do
            5.times { create :event, profile: profile }
            5.times { create :press_release, profile: profile }
          end

          specify do
            is_expected.not_to have_css '#events a', text: 'View All'
            is_expected.not_to have_css '#press a', text: 'View All'

            is_expected.not_to have_css '#press-events'

            is_expected.not_to have_css '#events'
            is_expected.not_to have_css '#press'

            is_expected.not_to have_css 'li.event', count: 2
            is_expected.not_to have_css 'li.press', count: 2
          end
        end
      end
    end
  end
end
