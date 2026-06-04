class Vendor::ProfilesController < Vendor::BaseController
  before_action :authenticate_user!
  before_action :set_vendor

  def show
  end

  def edit
  end

  def update
    if @vendor.update(vendor_params)
      redirect_to vendor_profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_vendor
    @vendor = current_user.vendor_profile
    if @vendor.nil?
      # Auto-create a blank vendor profile if missing (e.g. old signup flow)
      @vendor = Vendor.create!(
        user: current_user,
        shop_name: current_user.display_name || "My Shop",
        address: "Please update your address",
        approved: false
      )
    end
  end

  def vendor_params
    params.require(:vendor).permit(:shop_name, :address, :contact_number)
  end
end
