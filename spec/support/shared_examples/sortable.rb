require 'rails_helper'

shared_examples_for 'sortable' do
  let!(:profile) { create(:candidate_profile) }
  let!(:issue_category) { create :issue_category, profile: profile }

  let!(:model) { described_class }
  let!(:model_symbol) { model.to_s.underscore.to_sym }
  let!(:model_plural_symbol) { model.to_s.tableize.to_sym }

  let!(:model1) { build model_symbol, profile: profile }
  let!(:model2) { build model_symbol, profile: profile }
  let!(:model3) { build model_symbol, profile: profile }

  before do
    if model == Issue
      model1.issue_category = issue_category
      model2.issue_category = issue_category
      model3.issue_category = issue_category
    end

    model1.save
    model2.save
    model3.save
  end

  it 'should update positions' do
    array_of_ids = [model3.id, model1.id, model2.id]
    model.update_positions(array_of_ids)

    expect(profile.send(model_plural_symbol).by_position.map(&:id)).to eq array_of_ids
  end
end
