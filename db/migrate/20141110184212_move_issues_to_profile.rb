class MoveIssuesToProfile < ActiveRecord::Migration
  def up
    rename_column :issues, :account_id, :profile_id
    rename_column :issue_categories, :account_id, :profile_id

    Issue.where.not(profile_id: nil).find_each do |issue|
      issue.update_column(:profile_id, Profile.where(account_id: issue.profile_id).pluck(:id).first)
    end

    IssueCategory.where.not(profile_id: nil).find_each do |category|
      category.update_column(:profile_id, Profile.where(account_id: category.profile_id).pluck(:id).first)
    end
  end

  def down
    rename_column :issues, :profile_id, :account_id
    rename_column :issue_categories, :account_id, :profile_id

    Issue.where.not(account_id: nil).find_each do |issue|
      issue.update_column(:account_id, Profile.where(id: issue.account_id).pluck(:account_id).first)
    end

    IssueCategory.where.not(account_id: nil).find_each do |category|
      category.update_column(:account_id, Profile.where(id: category.account_id).pluck(:account_id).first)
    end
  end
end
