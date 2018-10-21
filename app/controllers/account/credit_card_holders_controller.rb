# Credit card hoder controller
class Account::CreditCardHoldersController < ApplicationController
  inherit_resources
  belongs_to :profile
  defaults singleton: true
  layout false, except: %i[create update]
  respond_to :js, only: %i[create update]
  before_action :authenticate_account!

  # GET /account/sites/:profile_id/credit_card_holder/new
  def new
    build_resource.build_credit_card
  end

  # POST /account/sites/:profile_id/credit_card_holder
  def create
    if params[:commit] == 'Apply'
      @price_check = true
      upgrader.check_coupon
    elsif upgrader.process
      flash[:notice] = 'Site successfully upgraded'
    end
    @update_card = false
    @new_price = upgrader.amount
  end

  def edit
    build_resource unless resource
    resource.build_credit_card unless resource.credit_card
  end

  # PATCH /account/sites/:profile_id/credit_card_holder
  def update
    resource.attributes = permitted_params[:credit_card_holder]
    flash[:notice] = 'Card successfully updated' if upgrader(resource).auth_test
    @update_card = true
    render :create, formats: :js
  end

  # DELETE /account/sites/:profile_id/credit_card_holder
  def destroy
    destroy!(notice: 'Site successfully downgraded') { request.referer }
  end

  private

  def permitted_params
    params.permit(:profile_id, credit_card_holder: [:first_name, :last_name, :city, :state, :zip, :address,
                                                    :coupon_code,
                                                    credit_card_attributes: [:id, :number, :cvv, :month, :year]])
  end

  def upgrader(res = build_resource)
    @upgrader ||= De::ProfileUpgrader.new(res)
  end
end
