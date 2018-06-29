require 'rails_helper'

describe CreditCard do
  describe 'relations' do
    it { expect(subject).to have_one :credit_card_holder }
  end

  describe 'validations' do
    describe 'format validations' do
      before do
        allow_any_instance_of(CreditCard).to receive(:card_type).and_return(true)
        allow_any_instance_of(CreditCard).to receive(:expiry_date).and_return(true)
      end

      it 'should validate number format' do
        ['4' * 16, '4' * 15].tap do |values|
          expect(subject).to allow_value(*values).for(:number)
        end

        ['abc', '4' * 18, 'a' * 16, 'a' * 15, '4' + 'a' * 15, '4' * 13, '4' * 7, nil, ''].each do |value|
          expect(subject).to_not allow_value(value).for(:number)
        end
      end

      it 'should validate CVV format' do
        ['4444', '444'].tap do |values|
          expect(subject).to allow_value(*values).for(:cvv)
        end

        ['abc', 'abcd', '44444', 'a1b', '4', '44', nil, ''].each do |value|
          expect(subject).not_to allow_value(value).for(:cvv)
        end
      end

      it 'should validate month' do
        MONTHS.tap do |values|
          expect(subject).to allow_value(*values).for(:month)
        end

        ['2', '13', '00', 'dd', '1d', nil, ''].each do |value|
          expect(subject).not_to allow_value(value).for(:month)
        end
      end

      it 'should validate year' do
        YEARS.tap do |values|
          expect(subject).to allow_value(*values).for(:year)
        end

        ['2', '13', '00', 'dd', '1d', nil, ''].each do |value|
          expect(subject).not_to allow_value(value).for(:year)
        end
      end
    end

    describe 'date validation' do
      let(:future_card) { build :credit_card, month: '12', year: (Time.current + 2.year).year.to_s }
      let(:past_card) { build :credit_card, month: '12', year: '2011' }

      it 'should validate that date is in future' do
        expect(future_card).to be_valid
        expect(past_card).to be_invalid
      end
    end

    describe '#card_type' do
      # remove 'last four' from donation
      # remove CC info from DE account model if ther's any
      describe 'accepting correctly formatted CC_number/CVV' do
        let(:visa) { build :credit_card, number: '4111111111111111', cvv: '123' }
        let(:mastercard) { build :credit_card, number: '5111111111111111', cvv: '123' }
        let(:discover) { build :credit_card, number: '6111111111111111', cvv: '123' }
        let(:amex) { build :credit_card, number: '311111111111111', cvv: '3123' }

        it 'should validate correct cards' do
          expect(visa).to be_valid
          expect(mastercard).to be_valid
          expect(discover).to be_valid
          expect(amex).to be_valid
        end
      end

      describe 'rejecting incorrect CC_number/CVV combinations' do
        let(:visa1) { build :credit_card, number: '4111111111111111', cvv: '3123' }
        let(:visa2) { build :credit_card, number: '411111111111111', cvv: '3123' }
        let(:mastercard1) { build :credit_card, number: '5111111111111111', cvv: '3123' }
        let(:mastercard2) { build :credit_card, number: '511111111111111', cvv: '3123' }
        let(:discover1) { build :credit_card, number: '611111111111111', cvv: '3123' }
        let(:discover2) { build :credit_card, number: '6111111111111111', cvv: '3123' }
        let(:amex1) { build :credit_card, number: '3111111111111111', cvv: '3123' }
        let(:amex2) { build :credit_card, number: '311111111111111', cvv: '123' }

        it 'should validate correct cards' do
          expect(visa1).to be_invalid
          expect(visa2).to be_invalid
          expect(mastercard1).to be_invalid
          expect(mastercard2).to be_invalid
          expect(discover1).to be_invalid
          expect(discover2).to be_invalid
          expect(amex1).to be_invalid
          expect(amex2).to be_invalid
        end
      end
    end

    describe '#expiry date' do
      context 'valid' do
        let!(:credit_card) { build :credit_card, month: '02', year: '2020' }
        specify { expect(credit_card).to be_valid }
      end

      context 'expired date' do
        let!(:credit_card) { build :credit_card, month: '01', year: '2016' }
        specify do
          expect(credit_card).to be_invalid
          expect(credit_card.errors[:year]).to include 'is not included in the list'
        end
      end

      context 'invalid date' do
        let!(:credit_card) { build :credit_card, month: 'OP', year: 'Oisv' }
        specify do
          expect(credit_card).to be_invalid
          expect(credit_card.errors[:base]).not_to include 'Card Expired'
          expect(credit_card.errors[:month]).to include 'is not included in the list'
          expect(credit_card.errors[:year]).to include 'is not included in the list'
        end
      end
    end
  end

  describe 'scopes' do
    describe '::about_to_expire' do
      let!(:card1) { CreditCard.new(exp_date: Date.today + 1.day) }
      let!(:card2) { CreditCard.new(exp_date: Date.today + 3.days) }
      let!(:card3) { CreditCard.new(exp_date: Date.today + 7.days) }
      let!(:card4) { CreditCard.new(exp_date: Date.today + 10.days) }

      before do
        allow_any_instance_of(CreditCard).to receive(:save_last_four)
        allow_any_instance_of(CreditCard).to receive(:save_exp_date)

        [card1, card2, card3, card4].each do |card|
          card.save(validate: false)
        end
      end

      specify do
        expect(CreditCard.about_to_expire).to match_array [card1, card3]
      end
    end
  end

  describe 'observers' do
    describe '#save_last_four' do
      let(:card) { create :credit_card, number: '4111111111111111' }
      it 'should save last 4 digits of the card' do
        expect(card.last_four).to eq '1111'
      end
    end

    describe '#save_exp_date' do
      let(:card) { create :credit_card, month: '02', year: '2020' }

      it 'should save card expiry date' do
        expect(card.exp_date).to eq '02/2020'.to_date
      end
    end
  end

end
