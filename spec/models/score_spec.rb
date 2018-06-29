require 'rails_helper'

describe Score do
  subject { build(:score) }

  it 'should have validations' do
    expect(subject).to validate_uniqueness_of(:ip).scoped_to(:scorable_id, :scorable_type)
    expect(subject).to validate_presence_of(:ip)
    expect(subject).to validate_presence_of(:scorable_id)
    expect(subject).to validate_presence_of(:scorable_type)
  end
end
