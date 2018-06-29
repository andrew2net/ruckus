class Domain < ActiveRecord::Base
  attr_accessor :new_account

  belongs_to :profile
  has_many :accounts, through: :profile, source: :accounts
  has_many :visits, dependent: :destroy, class_name: 'Request', as: :requestable

  validates :name, presence: true, uniqueness: true, domain_format: true
  validates :profile_id, presence: true

  before_validation :generate_random_name, if: :generate_random_name?
  before_validation :lowercase
  before_validation :set_internal
  before_destroy :can_destroy?

  scope :internal, -> { where(internal: true) }
  scope :external, -> { where(internal: [false, nil]) }

  def generate_random_name
    if profile.present?
      self.name = profile.name.to_s.parameterize
      self.name = name[0..24] if name.length > 25
      self.name = name.gsub(/\-\z/, '').gsub(/\A\-/, '')

      if Domain.where(name: name).exists?
        self.name = "#{name}-#{Digest::SHA1.hexdigest(Time.now.to_i.to_s)[1..7]}"
      end
    end
  end

  def verified?
    internal? || bound_to_our_ip?
  end

  private

  def bound_to_our_ip?
    IPSocket.getaddress(name) == SERVER_IP
  rescue SocketError
    false
  end

  def set_internal
    self.internal = !TLD.has_valid_tld?(name) if name.present? && internal.nil?
  end

  def lowercase
    name.downcase! if name.present?
  end

  def generate_random_name?
    new_account && name.blank?
  end

  def can_destroy?
    (internal? ? profile.domains.internal : profile.domains).count > 1
  end
end
