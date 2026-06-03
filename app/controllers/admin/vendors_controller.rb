class Admin::VendorsController < Admin::BaseController
  def index
    @vendors = Vendor.includes(:user).order(created_at: :desc)
  end

  def show
    @vendor = Vendor.find(params[:id])
    @orders = Order.where(vendor_id: @vendor.user_id).order(created_at: :desc).limit(10)
  end

  def approve
    @vendor = Vendor.find(params[:id])
    @vendor.update!(approved: true)
    redirect_to admin_vendors_path, notice: "Vendor approved successfully."
  end

  def reject
    @vendor = Vendor.find(params[:id])
    @vendor.update!(approved: false)
    redirect_to admin_vendors_path, notice: "Vendor rejected."
  end

  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.user.destroy
    redirect_to admin_vendors_path, notice: "Vendor deleted."
  end
end
