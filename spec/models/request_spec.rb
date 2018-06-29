require 'rails_helper'

describe Request do
  describe 'concerns' do
    it_behaves_like 'chartable'
  end

  it { expect(subject).to belong_to(:requestable) }
end
