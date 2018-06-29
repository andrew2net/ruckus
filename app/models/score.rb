class Score < ActiveRecord::Base
  validates :ip, presence: true, uniqueness: { scope: [:scorable_id, :scorable_type] }
  validates :scorable_id,   presence: true
  validates :scorable_type, presence: true
end
