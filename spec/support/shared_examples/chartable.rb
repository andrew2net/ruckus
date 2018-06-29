require 'rails_helper'

shared_examples_for 'chartable' do
  let!(:model) { described_class }
  let!(:model_symbol) { model.to_s.underscore.to_sym }

  it 'shows how many records were created each month' do
    create model_symbol, created_at: 4.months.ago
    create model_symbol, created_at: 4.months.ago

    create model_symbol, created_at: 3.months.ago
    create model_symbol, created_at: 3.months.ago
    create model_symbol, created_at: 3.months.ago

    create model_symbol, created_at: 2.months.ago

    create model_symbol, created_at: 1.months.ago
    create model_symbol, created_at: 1.months.ago
    create model_symbol, created_at: 1.months.ago
    create model_symbol, created_at: 1.months.ago

    model.count_by_month.tap do |all_records|
      all_records[0].tap do |record|
        expect(record.created_at).to eq 4.months.ago.beginning_of_month.to_date
        expect(record.count).to eq 2
      end

      all_records[1].tap do |record|
        expect(record.created_at).to eq 3.months.ago.beginning_of_month.to_date
        expect(record.count).to eq 3
      end
      
      all_records[2].tap do |record|
        expect(record.created_at).to eq 2.months.ago.beginning_of_month.to_date
        expect(record.count).to eq 1
      end

      all_records[3].tap do |record|
        expect(record.created_at).to eq 1.months.ago.beginning_of_month.to_date
        expect(record.count).to eq 4
      end
    end
  end

  it 'shows how many records were created each week' do
    create model_symbol, created_at: 4.weeks.ago
    create model_symbol, created_at: 4.weeks.ago

    create model_symbol, created_at: 3.weeks.ago
    create model_symbol, created_at: 3.weeks.ago
    create model_symbol, created_at: 3.weeks.ago

    create model_symbol, created_at: 2.weeks.ago

    create model_symbol, created_at: 1.weeks.ago
    create model_symbol, created_at: 1.weeks.ago
    create model_symbol, created_at: 1.weeks.ago
    create model_symbol, created_at: 1.weeks.ago

    model.count_by_week.tap do |all_records|
      all_records[0].tap do |record|
        expect(record.created_at).to eq 4.weeks.ago.beginning_of_week.to_date
        expect(record.count).to eq 2
      end

      all_records[1].tap do |record|
        expect(record.created_at).to eq 3.weeks.ago.beginning_of_week.to_date
        expect(record.count).to eq 3
      end
      
      all_records[2].tap do |record|
        expect(record.created_at).to eq 2.weeks.ago.beginning_of_week.to_date
        expect(record.count).to eq 1
      end

      all_records[3].tap do |record|
        expect(record.created_at).to eq 1.weeks.ago.beginning_of_week.to_date
        expect(record.count).to eq 4
      end
    end
  end

  it 'should switch method' do
    expect(model).to receive(:count_by_month)
    model.count_by(:month)

    expect(model).to receive(:count_by_week)
    model.count_by(:week)

    expect(model).to receive(:count_by_month)
    model.count_by(nil)
  end
end
