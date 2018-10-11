class Front::DonationsController < Front::BaseController
  inherit_resources
  belongs_to :profile
  respond_to :js, only: :create

  protect_from_forgery except: :create
  before_action :check_donation
  after_action :send_notification, only: :create

  def new
    new! do |format|
      mixpanel_tracker(parent.account).track_event :visitor_donate_cta
      format.html { render('new', layout: false) }
    end
  end

  def create
    create! do |success, failure|
      success.js do
        flash.now[:notice] = 'Thank you for your donation!'
        mixpanel_tracker(parent.account).track_event :visitor_donate_success,
                                                     donor_email:     resource.donor_email,
                                                     donor_name:      resource.donor_name,
                                                     donation_amount: resource.amount,
                                                     donation_date:   Date.today
        return render :create
      end

      failure.js { render :create }
    end
  end

private
  def check_donation
    unless parent.donations_on?
      render nil, status: 422
    end
  end

  def send_notification
    logger.info "Sending donation id: #{resource.id} notification..."
    if parent.donation_notifications_on? && resource.persisted?
      jid = AccountMailer.delay.donation_notification(parent.account, resource)
      logger.info "Sending doanation notification to recipient is completed. Job id: #{jid}"
      jid = AccountMailer.delay.donor_donation_notification(resource.id)
      logger.info "Sending doanation notification to donor is completed. Job id: #{jid}"
    end
  rescue Exception => e
    logger.info "Sending donation id: #{resource.id} failed. Error: #{e}"
  end

  def permitted_params
    params.permit(:account_id, donation: [:donor_first_name, :donor_middle_name, :donor_last_name,
                                          :donor_email, :donor_phone, :donor_address_1, :donor_address_2,
                                          :donor_city, :donor_state, :donor_zip, :employer_name,
                                          :employer_occupation, :employer_address, :employer_city,
                                          :employer_state, :employer_zip, :amount, :agree_with_terms,
                                          credit_card_attributes: [:number, :cvv, :month, :year]])
  end
end
