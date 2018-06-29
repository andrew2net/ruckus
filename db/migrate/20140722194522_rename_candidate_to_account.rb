class RenameCandidateToAccount < ActiveRecord::Migration
  def change
    rename_table :candidates, :accounts

    [:democracyengine_accounts, :domains, :donations, :educations, :events, :experiences,
     :issue_categories, :issues, :media, :oauth_accounts, :press_release_images, :press_releases,
     :profiles, :questions, :social_posts, :subscribers, :subscriptions].each do |table_name|
      rename_column table_name, :candidate_id, :account_id
    end
  end
end
