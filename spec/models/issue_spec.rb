require 'rails_helper'

describe Issue do
  subject { create(:issue) }

  describe 'concerns' do
    it_behaves_like 'sortable'
  end

  it 'should have associations' do
    expect(subject).to belong_to(:profile)
    expect(subject).to belong_to(:issue_category)
    expect(subject).to have_many(:scores)
    subject.scores.build
    expect(subject.scores.first.scorable_type).to eq 'Issue'
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:description) }
    it { expect(subject).to validate_presence_of(:issue_category_id) }

    context 'issue_category_id inclusion' do
      let(:profile) { subject.profile }
      let(:issue_category1) { subject.issue_category }
      let(:issue_category2) { create(:issue_category, profile: profile) }
      let(:issue_category3) { create(:issue_category, profile: profile) }
      let(:ids) { [issue_category1, issue_category2, issue_category3].map(&:id) }

      it { expect(subject).to validate_inclusion_of(:issue_category_id).in_array(ids) }
    end
  end

  describe 'scopes' do
    context '::by_position' do
      let(:issue1) { create(:issue, position: 3) }
      let(:issue2) { create(:issue, position: 1) }
      let(:issue3) { create(:issue, position: 2) }

      it 'should order' do
        Issue.update_positions([issue2.id, issue1.id, issue1.id])
        expect(Issue.by_position).to eq [issue2, issue3, issue1]
      end
    end
  end

  describe 'methods' do
    describe '#update_positions' do
      let(:issue1) { create(:issue) }
      let(:issue2) { create(:issue) }
      let(:issue3) { create(:issue) }

      specify do
        expect(Issue.by_position).to eq [issue1, issue2, issue3]
        Issue.update_positions([issue3.id.to_s, issue1.id.to_s, issue2.id.to_s])
        expect(Issue.by_position).to eq [issue3, issue1, issue2]
      end
    end
  end

  describe 'observers' do
    describe '#make_it_first_in_the_list' do
      let!(:issue_category) { create :issue_category }
      let!(:profile) { issue_category.profile }
      let!(:issue1) { create :issue, profile: profile, issue_category: issue_category }
      let!(:issue2) { create :issue, profile: profile, issue_category: issue_category }

      it 'should become first in profile press release list after create' do
        Issue.update_positions([issue1.id, issue2.id])
        issue3 = create :issue,  profile: profile, issue_category: issue_category
        expect(profile.issues.by_position).to eq [issue3, issue1, issue2]
      end
    end
  end
end
