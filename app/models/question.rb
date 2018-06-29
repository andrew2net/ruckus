class Question < ActiveRecord::Base
  belongs_to :user
  belongs_to :profile

  scope :by_created_at, -> { order('created_at DESC') }

  accepts_nested_attributes_for :user

  validates :text, presence: true
  validates :user_id, presence: true
  validates :profile_id, presence: true

  def add_user(params)
    self.user = user_from_params(params)
    profile.users << user if user.persisted? && !user.profiles.where(id: profile.id).exists?
    save
  end

  private

  def user_from_params(params)
    user = User.find_or_initialize_by(email: params[:email])
    user.update(params)

    user
  end
end
