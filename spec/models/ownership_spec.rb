require 'rails_helper'

describe Ownership do
  describe 'associations' do
    it { expect(subject).to belong_to(:profile) }
    it { expect(subject).to belong_to(:candidate_profile) }
    it { expect(subject).to belong_to(:organization_profile) }
    it { expect(subject).to belong_to(:account) }
  end

  describe 'observers' do
    describe '::make_others_editors' do
      let!(:admin)           { create :account, profile: profile }
      let!(:profile)         { create :candidate_profile }
      let!(:editor)          { create :account, profile: profile }
      let!(:ownership1)      { create :ownership, profile: profile, account: admin }
      let!(:ownership2)      { create :ownership, profile: profile, account: editor, type: 'EditorOwnership' }
      let(:editor_ownership) { editor.ownerships.where(profile_id: profile.id).first }

      specify do
        editor_ownership.make_admin
        expect(editor.ownerships.where(profile_id: profile.id).first.type).to eq 'AdminOwnership'
        expect(admin.ownerships.where(profile_id: profile.id).first.type).to eq 'EditorOwnership'
      end
    end
  end
end
