require 'rails_helper'

describe Percent::Cell do
  subject { cell('percent/', account).call }

  let(:account) { create :account, profile: profile }
  let(:profile) { create :candidate_profile }

  let(:progress_classes) do
    [Progress::SocialAccount, Progress::Donations, Progress::Biography, Progress::Photo, Progress::Issues,
     Progress::CampaignUpdate, Progress::BackgroundImage, Progress::HeroUnit, Progress::MediaStream,
     Progress::Events, Progress::PressReleases, Progress::ContactInfo, Progress::PersonalInformation]
  end

  let(:candidate_labels) do
    ['Add Photo', 'Add Candidate Information', 'Add Biography', 'Connect Social Account', 'Enable Donations',
     'Add Issues', 'Add Campaign Update', 'Add Background Image', 'Add Featured Media', 'Add to Photostream',
     'Add Events', 'Add Press', 'Add Contact Info']
  end

  let(:organization_labels) do
    ['Add Logo', 'Add Organization Information', 'Add Organization Statement', 'Connect Social Account',
     'Enable Donations', 'Add Priorities', 'Add Campaign Update', 'Add Background Image', 'Add Featured Media',
     'Add to Photostream', 'Add Events', 'Add Press', 'Add Contact Info']
  end

  def allow_any_progress_instance_to(something)
    progress_classes.each { |progress_class| allow_any_instance_of(progress_class).to something }
  end

  describe 'Percent' do
    before { allow_any_progress_instance_to receive(:completed_percent).and_return(1) }

    specify do
      is_expected.to have_css '.progress-percent h1', text: '13% Complete'
    end
  end

  describe 'Active or not' do
    specify 'active' do
      allow_any_progress_instance_to receive(:completed?).and_return(true)
      candidate_labels.each { |text| expect(subject).to have_css 'a.active', text: text }
    end

    specify 'inactive' do
      allow_any_progress_instance_to receive(:completed?).and_return(false)
      candidate_labels.each { |text| expect(subject).to have_css 'a:not(.active)', text: text }
    end
  end

  describe 'Labels' do
    specify 'Candidate' do
      candidate_labels.each { |text| expect(subject).to have_link text }
    end

    context 'Organization' do
      let(:profile) { create(:organization_profile) }
      specify { organization_labels.each { |text| expect(subject).to have_link text } }
    end
  end

  describe 'Completed Items' do
    let(:progress_classes) { [Progress::Issues, Progress::MediaStream, Progress::Events, Progress::PressReleases] }

    before { allow_any_progress_instance_to receive(:completed_items_count).and_return(completed_items_count) }

    context 'no items are completed' do
      let(:completed_items_count) { 0 }

      specify do
        expect(subject).to have_link 'Add Issues 0 / 3'
        expect(subject).to have_link 'Add to Photostream 0 / 5'
        expect(subject).to have_link 'Add Events 0 / 2'
        expect(subject).to have_link 'Add Press 0 / 2'
      end
    end

    context '1 item is completed' do
      let(:completed_items_count) { 1 }

      specify do
        expect(subject).to have_link 'Add Issues 1 / 3'
        expect(subject).to have_link 'Add to Photostream 1 / 5'
        expect(subject).to have_link 'Add Events 1 / 2'
        expect(subject).to have_link 'Add Press 1 / 2'
      end
    end

    context '2 items are completed' do
      let(:completed_items_count) { 2 }

      specify do
        expect(subject).to have_link 'Add Issues 2 / 3'
        expect(subject).to have_link 'Add to Photostream 2 / 5'
        expect(subject).to have_link 'Add Events 2 / 2'
        expect(subject).to have_link 'Add Press 2 / 2'
      end
    end
  end
end
