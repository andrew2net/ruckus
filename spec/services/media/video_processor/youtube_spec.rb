require 'rails_helper'

describe Media::VideoProcessor::Youtube, cassette_name: :youtube_video do
  let!(:video_url) { VIDEOS[:youtube][:url] }
  let!(:medium) { create :medium, image: nil, video_url: video_url }
  let!(:thumbnail_generator) { described_class.new(medium) }

  describe '#process' do
    it 'should generate thumbnail' do
      thumbnail_generator.process

      medium.reload.tap do |medium|
        expect(File.basename(medium.image_url)).to eq VIDEOS[:youtube][:thumbnail_name]
        expect(medium.video_embed_url).to eq VIDEOS[:youtube][:embed_url]
      end
    end
  end

  describe 'video without thumbnail' do
    let(:video_url) { 'http://www.youtube.com/watch?v=CUtBhF-6RKs' }
    let(:medium) { create :medium, video_url: video_url }

    it 'should set default thumbnail url' do
      thumbnail_generator.process

      medium.reload.tap do |medium|
        expect(File.basename(medium.image_url)).to eq 'default.jpg'
        expect(medium.video_embed_url).to eq '//www.youtube.com/embed/CUtBhF-6RKs'
      end
    end
  end
end
