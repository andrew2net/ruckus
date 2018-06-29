require 'rails_helper'

describe CandidateProfile do
  it_behaves_like 'Profile'

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:first_name) }
    it { expect(subject).to validate_presence_of(:last_name) }
    it { expect(subject).to ensure_length_of(:first_name).is_at_least(2).is_at_most(25) }
    it { expect(subject).to ensure_length_of(:last_name).is_at_least(2).is_at_most(25) }
    it { expect_to_validate_format_field(:first_name) }
    it { expect_to_validate_format_field(:last_name) }
  end

  describe 'observers' do
    describe 'before_validation: generate_display_name' do
      it 'should generate the display name' do
        profile = create(:candidate_profile, first_name: 'John', last_name: 'Smith')
        expect(profile.reload.name).to eq 'John Smith'
      end

      it 'should not overwrite existing display name' do
        profile = create(:candidate_profile, first_name: 'John',
                                             last_name:  'Smith',
                                             name:       'Bob Marley Johnson')
        expect(profile.reload.name).to eq 'Bob Marley Johnson'
      end
    end
  end
end
