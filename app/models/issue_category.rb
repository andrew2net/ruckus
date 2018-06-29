class IssueCategory < ActiveRecord::Base
  has_many :issues, dependent: :destroy
  belongs_to :profile

  validates :name, presence: true

  def national_security?
    name == 'National Security'
  end
end
