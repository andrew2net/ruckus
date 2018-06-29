class Issue < ActiveRecord::Base
  include Sortable

  belongs_to :profile
  belongs_to :issue_category
  has_many :scores, as: :scorable

  validates :title, presence: true
  validates :description, presence: true
  validates :profile_id, presence: true
  validates :issue_category_id, presence: true, inclusion: { in: :allowed_category_ids }

  after_create :make_it_first_in_the_list

  private

  def allowed_category_ids
    profile.allowed_categories.pluck(:id)
  end

  def make_it_first_in_the_list
    old_list = profile.issues.by_position.pluck(:id)
    new_list = old_list.unshift(id)
    Issue.update_positions(new_list)
  end
end
