class Account::CreditCardHoldersController < ApplicationController
  inherit_resources
  belongs_to :profile
  defaults singleton: true
  layout false, except: :create
  respond_to :js, only: :create
  before_action :authenticate_account!

  def new
    build_resource.build_credit_card
  end

  def create
    if params[:commit] == 'Apply'
      @price_check = true
      upgrader.check_coupon
    else
      flash[:notice] = 'Site successfully upgraded' if upgrader.process
    end
    @new_price = upgrader.amount
  end

  def destroy
    destroy!(notice: 'Site successfully downgraded') { request.referer }
  end

  private

  def permitted_params
    params.permit(:profile_id, credit_card_holder: [:first_name, :last_name, :city, :state, :zip, :address,
                                                    :coupon_code,
                                                    credit_card_attributes: [:number, :cvv, :month, :year]])
  end

  def upgrader
    @upgrader ||= De::ProfileUpgrader.new(build_resource)
  end
end
