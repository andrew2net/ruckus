require 'rails_helper'

describe De::ProfileUpgrader do
  subject { described_class.new(card_holder) }

  let(:profile) { create :candidate_profile, suspended: suspended? }
  let(:account) { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let(:suspended?) { false }

  describe '#process', :unstub_de do
    let(:card_data) do
      {
        number: '4111111111111111',
        cvv:    '123',
        month:  '02',
        year:   (Time.current + 2.year).year.to_s
      }
    end

    let(:default_card_holder_data) do
      {
        first_name: 'John',
        last_name:  'Doe',
        state:      'CA',
        city:       'Louisiana',
        zip:        '12345',
        address:    'Street',
        token:      nil,
        profile:    profile
      }
    end

    let(:default_de_api_data) do
      {
        donor_first_name:      'John',
        donor_last_name:       'Doe',
        donor_city:            'Louisiana',
        donor_state:           'CA',
        donor_zip:             '12345',
        donor_address1:        'Street',
        cc_number:             '4111111111111111',
        cc_verification_value: '123',
        cc_month:              '02',
        cc_year:               (Time.current + 2.year).year.to_s,
        cc_first_name:         'John',
        cc_last_name:          'Doe',
        token_request:         true,
        line_items: [{
          amount:       amount,
          recipient_id: described_class::REMOTE_RECIPIENT_ID
        }]
      }
    end

    context 'new card' do
      let(:card_holder) { build(:credit_card_holder, card_holder_data.merge(credit_card: card)) }
      let(:card) { build(:credit_card, card_data) }

      context 'real' do
        let(:card_holder_data) { default_card_holder_data }
        let(:de_api_data) { default_de_api_data }

        before do
          allow(card_holder).to receive(:real?).and_return(true)
          expect(card).to_not be_persisted
          expect(card_holder).to_not be_persisted
          allow(DEApi).to receive(:create_donation).with(de_api_data).and_return(de_api_response)
        end

        context 'success' do
          let(:de_api_response) { { 'token' => 'new-card-token' } }
          let(:coupon_expired?) { false }
          let(:suspended?) { true }

          before do
            allow_any_instance_of(Coupon).to receive(:expired?).and_return(coupon_expired?)
            Sidekiq::Testing.inline! { expect(subject.process).to be_truthy }
            expect(card).to be_persisted
            expect(card_holder).to be_persisted
            expect(card_holder.profile).not_to be_suspended
            expect(card_holder.token).to eq 'new-card-token'
            expect(PremiumMailer.deliveries.count).to eq 1
          end

          context 'without coupon' do
            let(:amount) { '$20' }
            specify {}
          end

          context 'with coupon' do
            let(:coupon) { build(:coupon, discount: 23) }
            let(:card_holder_data) { default_card_holder_data.merge(coupon: coupon) }

            context 'expired' do
              let(:coupon_expired?) { true }
              let(:amount) { '$20' }

              specify {}
            end

            context 'not expired' do
              let(:coupon_expired?) { false }
              let(:amount) { '$15.4' }

              specify {}
            end
          end
        end

        context 'failure' do
          let(:de_api_response) { [['a', 'Error A'], ['b', 'Error B']] }
          let(:amount) { '$20' }

          specify do
            Sidekiq::Testing.inline! { expect(subject.process).to be_falsey }
            expect(card).to_not be_persisted
            expect(card_holder).to_not be_persisted
            expect(card_holder.errors[:base]).to eq ['Error A, Error B']
            expect(PremiumMailer.deliveries.count).to be_zero
          end
        end
      end

      context 'invalid' do
        let(:card_holder_data) { default_card_holder_data }

        before { allow(card_holder).to receive(:real?).and_return(false) }

        specify do
          Sidekiq::Testing.inline! { expect(subject.process).to be_falsey }
          expect(card).to_not be_persisted
          expect(card_holder).to_not be_persisted
          expect(PremiumMailer.deliveries.count).to be_zero
        end
      end
    end

    context 'old card' do
      let(:card_holder) { create(:credit_card_holder, card_holder_data.merge(credit_card: card)) }
      let(:card) { create(:credit_card, card_data).reload }
      let(:card_holder_data) { default_card_holder_data.merge(token: 'old-token') }
      let(:de_api_data) { default_de_api_data.merge(token_request: false, token: 'old-token') }

      before do
        allow(DEApi).to receive(:create_donation).with(de_api_data).and_return(de_api_response)
        allow(card_holder).to receive(:real?).and_return(true)
      end

      context 'success' do
        let(:de_api_response) { { 'token' => 'old-token' } }

        after do
          Sidekiq::Testing.inline! { expect(subject.process).to be_truthy }
          expect(PremiumMailer.deliveries.count).to eq 1
        end

        context 'without coupon' do
          let(:amount) { '$20' }
          specify {}
        end

        context 'with coupon' do
          let(:card_holder_data) { default_card_holder_data.merge(token: 'old-token', coupon: coupon) }
          let(:coupon) { create(:coupon, discount: 23) }

          before { allow_any_instance_of(Coupon).to receive(:expired?).and_return(coupon_expired?) }

          context 'expired' do
            let(:coupon_expired?) { true }
            let(:amount) { '$20' }

            specify {}
          end

          context 'not expired' do
            let(:coupon_expired?) { false }
            let(:amount) { '$15.4' }

            specify {}
          end
        end
      end
    end
  end
end
