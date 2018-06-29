require 'rails_helper'

describe PressReleaseParser do
  let(:parser) { PressReleaseParser.new(link) }
  let(:today) { Time.now.strftime('%d %B %Y') }
  let(:link) { 'http://www.ted.com/talks/clayton_cameron_a_rhythm_etic_the_math_behind_the_beats' }

  describe '#scrape', cassette_name: 'scraper_test' do
    describe 'with valid link' do
      let(:result) do
        {
          title:      "Clayton Cameron:\n\n\nA-rhythm-etic. The math behind the beats",
          page_title: "Clayton Cameron: A-rhythm-etic. The math behind the beats | Talk Video | TED",
          page_date:  today,
          url: "http://www.ted.com/talks/clayton_cameron_a_rhythm_etic_the_math_behind_the_beats"
        }
      end

      context 'stripped' do
        it 'should scrape' do
          expect(parser.scrape).to eq result
          expect(parser).to be_valid
        end
      end

      context 'unstripped' do
        let(:link) { ' http://www.ted.com/talks/clayton_cameron_a_rhythm_etic_the_math_behind_the_beats ' }

        it 'should scrape' do
          expect(parser.scrape).to eq result
          expect(parser).to be_valid
        end
      end

      context 'link that redirects somewhere else' do
        let(:link) { 'http://www.nytimes.com/2014/04/09/world/asia/muslim-shrine-stands-as-a-crossroads-in-syrias-unrest.html?hp&_r=5' }

        it 'should give a link error but not crash' do
          expect(parser).to be_valid
        end
      end
    end


    describe 'with invalid link' do
      context 'invalid format' do
        let(:link) { 'xyz' }

        it 'should return an empty data' do
          expect(parser.scrape).to eq title:      '',
                                      page_title: '',
                                      page_date:  today,
                                      url:        'xyz'
          expect(parser).to_not be_valid
          expect(parser.errors[:url]).to eq 'invalid link'
        end
      end

      context 'nonexistent url' do
        let(:link) { 'http://example.com/example' }

        it 'should return an empty data' do
          expect(parser.scrape).to eq title:      '',
                                      page_title: '',
                                      page_date:  today,
                                      url:        'http://example.com/example'
          expect(parser).to_not be_valid
          expect(parser.errors[:url]).to eq 'service not found'
        end
      end

      context 'not encode url' do
        let(:link) { 'http://www.mlive.com/news/ann-arbor/index.ssf/2014/09/whitmore_lake_schools_annexati_2.html#incart_river' }

        it 'should not encode' do
          expect(parser.instance_variable_get(:@url)).to eq link
        end
      end

      context 'non html link', cassette_name: 'scraper_pdf' do
        let(:link) { 'http://www.friendsofharford.com/election/kazimir.pdf' }

        it 'should return an empty data' do
          expect(parser.scrape).to eq title: '', page_title: '', page_date: today, url: link
          expect(parser).to_not be_valid
          expect(parser.errors[:url]).to eq 'only html pages allowed'
        end
      end

      context 'empty url' do
        let(:link) { nil }

        it 'should return an empty data' do
          expect(parser.scrape).to eq title: '', page_title: '', page_date: today, url: ''
          expect(parser).to_not be_valid
          expect(parser.errors[:url]).to eq 'invalid link'
        end
      end

      context 'link with HTML inside first h1' do
        let(:link) { 'https://www.flickr.com/photos/whitehouse ' }

        it 'should copy text - not all the html tags & spaces around it' do
          expect(parser.scrape[:title]).to eq 'The White House'
        end
      end

      context 'link to the page with broken image' do
        let(:link) { 'http://www.usatoday.com/story/news/world/2014/04/20/ukraine-shootout/7933877/' }

        it 'should handle broken images' do
          expect(parser).to be_valid
        end
      end

      context 'link to the page that refuses connection' do
        let(:link) { 'http://127.0.0.1:5000/' }

        it 'should give connection refused error' do
          expect(parser).to_not be_valid
          expect(parser.errors[:url]).to eq 'connection refused'
        end
      end
    end
  end

  describe '#images', cassette_name: 'scraper_test' do
    it 'should only return images with size > 50kb' do
      expect(parser.images.size).to eq 1
      expect(parser.images.first.size).to be >= 50 * 1024
      expect(parser).to be_valid
    end
  end
end
