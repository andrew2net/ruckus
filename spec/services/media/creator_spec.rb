require 'rails_helper'

describe Media::Creator do
  subject { described_class.new(profile, options) }
  let(:profile) { create(:candidate_profile) }

  describe 'without options' do
    let(:options) { {} }
    specify { expect { expect(subject.create).to be_nil }.to_not change(Medium, :count) }
  end

  describe 'images' do
    let(:image1) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }
    let(:image2) { File.open(Rails.root.join('spec', 'fixtures', 'image2.jpg')) }
    let(:options) { { images: [image1, image2] } }

    specify do
      expect { expect(subject.create.image_url).to end_with 'image2.jpg' }.to change(Medium, :count).by(2)
    end
  end

  describe 'video' do
    let(:options) { { video_url: video_url } }

    context 'youtube' do
      let(:video_url) { VIDEOS[:youtube][:url] }
      let(:processor_class) { Media::VideoProcessor::Youtube }

      specify do
        expect(processor_class).to receive(:new).and_call_original
        expect_any_instance_of(processor_class).to receive(:process)
        expect { expect(subject.create.video_url).to eq video_url }.to change(Medium, :count).by(1)
      end
    end

    context 'vimeo' do
      let(:video_url) { VIDEOS[:vimeo][:url] }
      let(:processor_class) { Media::VideoProcessor::Vimeo }

      specify do
        expect(processor_class).to receive(:new).and_call_original
        expect_any_instance_of(processor_class).to receive(:process)
        expect { expect(subject.create.video_url).to eq video_url }.to change(Medium, :count).by(1)
      end
    end

    context 'other' do
      let(:video_url) { 'http://thedailyshow.cc.com/videos/8x3wxa/moment-of-zen---jon-s-announcement' }

      specify do
        expect { subject.create }.to change(Medium, :count).by(0)
      end
    end
  end
end
