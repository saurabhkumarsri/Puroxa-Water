class Subadmin::VendorsController < Subadmin::BaseController
  def index
    @vendors = Vendor.includes(:user).order(created_at: :desc)
  end

  def show
    @vendor = Vendor.find(params[:id])
    @orders = Order.where(vendor_id: @vendor.user_id).order(created_at: :desc).limit(10)
  end
end
