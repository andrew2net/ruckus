require 'rails_helper'

describe SubscribeForm::Cell do
  subject { cell('subscribe_form/', profile: profile.decorate, user: User.new).call }

  let(:profile) do
    create(:candidate_profile, register_to_vote_url: 'https://google.com',
                               register_to_vote_on:  register_to_vote_on)
  end

  describe do
    context 'register_to_vote_on is true' do
      let(:register_to_vote_on) { true }
      specify { is_expected.to have_link 'Register to Vote', href: 'https://google.com' }
    end

    context 'register_to_vote_on is false' do
      let(:register_to_vote_on) { false }
      specify { is_expected.to have_no_link 'Register to Vote' }
    end
  end
end
