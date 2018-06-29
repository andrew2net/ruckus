class CreateNewIssueCategory < ActiveRecord::Migration
  CATEGORY_NAME = 'National Security' 

  def up
    IssueCategory.find_or_create_by_name(name: CATEGORY_NAME)
    rescue NameError
    puts 'Model does not exist'
  end

  def down
    IssueCategory.where(name: CATEGORY_NAME).destroy_all
    rescue NameError
    puts 'Model does not exist'
  end
end
