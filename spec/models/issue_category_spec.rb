require 'rails_helper'

describe IssueCategory do
  describe 'associations' do
    it { expect(subject).to belong_to(:profile) }
    it { expect(subject).to have_many(:issues).dependent(:destroy) }
  end

  it 'should have validations' do
    expect(subject).to validate_presence_of(:name)
  end

  describe '#national_security?' do
    let(:national_security_category) { build :issue_category, name: 'National Security' }
    let(:some_other_category) { build :issue_category, name: SecureRandom.hex }

    it 'should say if this is National Security category' do
      expect(national_security_category.national_security?).to be_truthy
      expect(some_other_category.national_security?).to be_falsey
    end
  end
end
