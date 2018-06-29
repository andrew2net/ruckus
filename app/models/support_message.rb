class SupportMessage < ActiveRecord::Base
  validates :subject, presence: true
  validates :name, presence: true
  validates :message, presence: true
  validates :email, presence: true, email: { strict_mode: true }

  after_create :deliver_message

  private
  def deliver_message
    AccountMailer.support_message(self).deliver
  end
end
