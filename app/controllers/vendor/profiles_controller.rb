class Vendor::ProfilesController < Vendor::BaseController
  before_action :authenticate_user!

  def show
    @vendor = current_user.vendor_profile
  end

  def edit
    @vendor = current_user.vendor_profile
  end

  def update
    @vendor = current_user.vendor_profile
    if @vendor.update(vendor_params)
      redirect_to vendor_profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:shop_name, :address, :contact_number)
  end
end
