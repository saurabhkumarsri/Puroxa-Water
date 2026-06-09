class Customer::LandingController < ApplicationController
  before_action :redirect_if_authenticated

  def index
    @products = Product.active.limit(6)
    @total_customers = User.where(role: User::ROLES[:customer]).count
    @total_vendors    = User.where(role: User::ROLES[:vendor]).count
    @total_orders     = Order.count
    @areas            = User.where.not(area: nil).where.not(area: "").distinct.pluck(:area).first(8)
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
