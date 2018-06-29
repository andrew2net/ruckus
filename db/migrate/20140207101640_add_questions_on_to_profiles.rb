class AddQuestionsOnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :questions_on, :boolean, default: true
  end
end
