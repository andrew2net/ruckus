class Ownership < ActiveRecord::Base
  belongs_to :account

  belongs_to :profile
  belongs_to :candidate_profile, foreign_key: :profile_id
  belongs_to :organization_profile, foreign_key: :profile_id

  def make_admin
    update type: 'AdminOwnership'
    profile.admin_ownerships.where.not(id: id).update_all type: 'EditorOwnership' if type == 'AdminOwnership'
  end
end
