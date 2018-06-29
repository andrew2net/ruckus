class User < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :profiles, through: :subscriptions

  validates :email, presence: true, email: { strict_mode: true }, uniqueness: true

  scope :search, -> (value) { where('email ILIKE :q', q: "%#{value}%") }

  def self.subscribe(email, profile)
    user = find_or_initialize_by(email: email)
    user.subscribed = true

    if user.persisted? && user.profiles.exists?(profile)
      user.save
      user.errors.add(:email, 'You are already subscribed')
    else
      user.profiles << profile
      user.save
    end

    user
  end

  def name
    [first_name, last_name].select(&:present?).join(' ')
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end
end
