class Admin::CouponsController < Admin::BaseController
  inherit_resources

  def update
    update! do |success, failure|
      success.html { redirect_to admin_coupons_path }
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to admin_coupons_path }
    end
  end

  private

  def permitted_params
    params.permit(coupon: [:code, :discount, :expired_at])
  end
end
