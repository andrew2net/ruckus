require 'rails_helper'

describe ProfileDecorator do
  let(:profile) { create(:candidate_profile) }
  let(:profile_decorator) { profile.decorate }
  let(:profile_decorator_editing) { profile.decorate(context: { account_editing: true }) }

  describe '#candidate?' do
    let(:candidate_profile) { create(:candidate_profile).decorate }
    let(:organization_profile) { create(:organization_profile).decorate }

    specify do
      expect(candidate_profile).to be_candidate
      expect(candidate_profile).not_to be_organization

      expect(organization_profile).not_to be_candidate
      expect(organization_profile).to be_organization
    end
  end
end
