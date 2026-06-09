class Customer::LandingController < ApplicationController
  before_action :redirect_if_authenticated

  def index
    @products = Product.active.limit(4)
  end

  private

  def redirect_if_authenticated
    return unless current_user

    if current_user.admin?
      redirect_to admin_dashboard_path and return
    elsif current_user.subadmin?
      redirect_to subadmin_dashboard_path and return
    elsif current_user.customer?
      redirect_to customer_dashboard_path and return
    elsif current_user.vendor?
      redirect_to vendor_dashboard_path and return
    end
  end
end
