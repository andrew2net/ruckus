require 'rails_helper'

describe EventsHelper  do
  describe '#time_in_dashboard' do
    let!(:event1) do
      build :event, start_time: Time.parse('3 June 2015 15:42 EST'),
                    city: 'City1',
                    state: 'NY',
                    show_start_time: true
    end

    let!(:event2) do
      build :event, start_time: Time.parse('4 June 2015 15:42 EST'),
                    city: 'City2',
                    state: 'CO',
                    show_start_time: false
    end

    it 'should format time' do
      expect(helper.time_in_dashboard(event1)).to eq 'June 03 · 4PM · City1, NY'
      expect(helper.time_in_dashboard(event2)).to eq 'June 04 · City2, CO'
    end
  end
end
