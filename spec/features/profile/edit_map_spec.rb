require 'rails_helper'

describe 'Edit Map' do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { login_as(account, scope: :account) }

  let(:builder_overlay_path) { profile_edit_map_path }
  it_behaves_like 'Builder overlay'
end
