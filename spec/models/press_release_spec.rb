require 'rails_helper'

describe PressRelease do
  subject { create(:press_release) }

  describe 'concerns' do
    it_behaves_like 'sortable'
  end

  let(:image) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

  describe 'associations' do
    it { expect(subject).to belong_to :profile }

    describe 'press_release_images' do
      let!(:press_release) { create(:press_release) }
      let!(:image1) { create(:press_release_image, profile: press_release.profile) }
      let!(:image2) { create(:press_release_image, press_release_url: press_release.url) }
      let!(:image3) do
        create(:press_release_image, profile:         press_release.profile,
                                     press_release_url: press_release.url)
      end

      specify { expect(press_release.press_release_images).to eq [image3] }
    end
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:profile) }
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:url) }
    it { expect_to_validate_url_format(:url) }
    it { expect(subject).to validate_uniqueness_of(:url).scoped_to(:profile_id) }
  end

  describe 'scopes' do
    specify '::by_position/::by_position_desc' do
      press_release1 = create(:press_release)
      press_release2 = create(:press_release)
      press_release3 = create(:press_release)

      PressRelease.update_positions([press_release2.id, press_release3.id, press_release1.id])

      expect(PressRelease.by_position).to eq [press_release2, press_release3, press_release1]
      expect(PressRelease.by_position_desc).to eq [press_release1, press_release3, press_release2]
    end
  end

  describe '#create_images' do
    let!(:press_release_image) do
      create(:press_release_image, press_release_url: subject.url,
                                   profile:         subject.profile)
    end

    specify do
      expect(subject.press_release_images).to eq [press_release_image]

      subject.create_images([image])

      press_release_images = subject.press_release_images.to_a
      expect(press_release_images.size).to eq 1
      expect(press_release_images).to_not eq [press_release_image]
    end
  end

  describe '#active_image && active_image_id' do
    context 'when has not images' do
      it 'should be nil' do
        expect(subject.active_image).to be_nil
        expect(subject.active_image_id).to be_nil
      end
    end

    context 'when has only inactive images' do
      let!(:inactive_image) do
        create(:press_release_image, press_release_url: subject.url,
                                     profile:         subject.profile,
                                     active:            false)
      end

      it 'should be first image' do
        expect(subject.active_image).to eq inactive_image
        expect(subject.active_image_id).to eq inactive_image.id
      end
    end

    context 'when has active and inactive images' do
      let!(:active_image) do
        create(:press_release_image, press_release_url: subject.url,
                                     profile:         subject.profile,
                                     active:            true)
      end

      let!(:inactive_image) do
        create(:press_release_image, press_release_url: subject.url,
                                     profile:         subject.profile,
                                     active:            false)
      end

      it 'should be active image' do
        expect(subject.active_image).to eq active_image
        expect(subject.active_image_id).to eq active_image.id
      end
    end
  end

  describe '#display_page_thumbnail?' do
    context 'when has not an active image' do
      context 'and page_thumbnail_enabled is false' do
        let(:press_release) { create(:press_release, page_thumbnail_enabled: false) }

        it 'should return false' do
          expect(press_release.display_page_thumbnail?).to be_falsey
        end
      end

      context 'and page_thumbnail_enabled is true' do
        let(:press_release) { create(:press_release, page_thumbnail_enabled: true) }

        it 'should return false' do
          expect(press_release.display_page_thumbnail?).to be_falsey
        end
      end
    end

    context 'when has an active image' do
      let!(:active_image) do
        create(:press_release_image, press_release_url: press_release.url,
                                     profile:         press_release.profile,
                                     active:            true)
      end

      context 'and page_thumbnail_enabled is false' do
        let(:press_release) { create(:press_release, page_thumbnail_enabled: false) }

        it 'should return false' do
          expect(press_release.display_page_thumbnail?).to be_falsey
        end
      end

      context 'and page_thumbnail_enabled is true' do
        let(:press_release) { create(:press_release, page_thumbnail_enabled: true) }

        it 'should return true' do
          expect(press_release.display_page_thumbnail?).to be_truthy
        end
      end
    end
  end

  describe '#display_page_title?' do
    let(:press_release) { build(:press_release, params) }
    let(:params) { {} }

    context 'when page_title is blank' do
      before { params.merge!(page_title: ' ') }

      context 'and page_title_enabled is false' do
        before { params.merge!(page_title_enabled: false) }

        it 'should return false' do
          expect(press_release.display_page_title?).to be_falsey
        end
      end

      context 'and page_title_enabled is true' do
        before { params.merge!(page_title_enabled: true) }

        it 'should return false' do
          expect(press_release.display_page_title?).to be_falsey
        end
      end
    end

    context 'when page_title is not blank' do
      before { params.merge!(page_title: 'Page Title') }

      context 'and page_title_enabled is false' do
        before { params.merge!(page_title_enabled: false) }

        it 'should return false' do
          expect(press_release.display_page_title?).to be_falsey
        end
      end

      context 'and page_title_enabled is true' do
        before { params.merge!(page_title_enabled: true) }

        it 'should return false' do
          expect(press_release.display_page_title?).to be_truthy
        end
      end
    end
  end

  describe '#display_page_date?' do
    let(:press_release) { build(:press_release, params) }
    let(:params) { {} }

    context 'when page_date is nil' do
      before { params.merge!(page_date: nil) }

      context 'and page_date_enabled is false' do
        before { params.merge!(page_date_enabled: false) }

        it 'should return false' do
          expect(press_release.display_page_date?).to be_falsey
        end
      end

      context 'and page_date_enabled is true' do
        before { params.merge!(page_date_enabled: true) }

        it 'should return false' do
          expect(press_release.display_page_date?).to be_falsey
        end
      end
    end

    context 'when page_date is not nil' do
      before { params.merge!(page_date: Time.now) }

      context 'and page_date_enabled is false' do
        before { params.merge!(page_date_enabled: false) }

        it 'should return false' do
          expect(press_release.display_page_date?).to be_falsey
        end
      end

      context 'and page_date_enabled is true' do
        before { params.merge!(page_date_enabled: true) }

        it 'should return false' do
          expect(press_release.display_page_date?).to be_truthy
        end
      end
    end
  end

  describe '#active_image_id=' do
    let!(:image) do
      create(:press_release_image, press_release_url: subject.url,
                                   profile:         subject.profile,
                                   active:            false)
    end

    specify do
      expect(image).to_not be_active
      subject.update_attribute(:active_image_id, image.id)
      expect(image.reload).to be_active
    end
  end

  describe 'observers' do
    describe '::new_from_url' do
      before { allow_any_instance_of(PressReleaseParser).to receive(:page).and_return('') }

      let(:profile) { create(:candidate_profile) }
      let(:press_release) { profile.press_releases.new(url: 'http://example999.com', build_from_url: true) }

      it 'should not create a press_release' do
        press_release.valid?
        expect(press_release).to be_new_record
        expect(press_release.errors.messages[:url]).to eq ['service not found']
      end

      it 'should create a press_release' do
        press_release.url = 'https://www.google.com.ua'

        allow_any_instance_of(PressReleaseParser).to receive(:valid?).and_return(true)
        allow_any_instance_of(PressReleaseParser).to receive(:images).and_return([image])
        allow_any_instance_of(PressReleaseParser).to receive(:scrape).and_return(
          title:      'title',
          page_title: 'page_title',
          page_date:  Time.now.strftime('%d %B %Y'),
          url:        'http://example.com/example'
        )

        press_release.valid?

        expect(press_release).to be_new_record
        expect(press_release).to be_valid
        expect(press_release.press_release_images.count).to eq 1
      end
    end

    describe '#make_it_first_in_the_list' do
      let!(:profile) { create :candidate_profile }
      let!(:press_release1) { create :press_release, profile: profile }
      let!(:press_release2) { create :press_release, profile: profile }

      it 'should become first in account press release list after create' do
        PressRelease.update_positions([press_release1.id, press_release2.id])
        press_release3 = create :press_release,  profile: profile
        expect(PressRelease.by_position).to eq [press_release3, press_release1, press_release2]
      end
    end
  end

end
