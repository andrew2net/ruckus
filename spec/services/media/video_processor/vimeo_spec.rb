require 'rails_helper'

describe Media::VideoProcessor::Vimeo, cassette_name: :vimeo_video do
  let!(:video_url) { VIDEOS[:vimeo][:url] }
  let!(:medium) { create :medium, image: nil, video_url: video_url }
  let!(:video_processor) { described_class.new(medium) }

  describe '#process' do
    specify do
      video_processor.process

      medium.reload.tap do |medium|
        expect(File.basename(medium.image_url)).to eq VIDEOS[:vimeo][:thumbnail_name]
        expect(medium.video_embed_url).to eq VIDEOS[:vimeo][:embed_url]
      end
    end
  end
end
