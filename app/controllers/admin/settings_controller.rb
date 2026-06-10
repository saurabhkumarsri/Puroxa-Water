class Admin::SettingsController < Admin::BaseController
  def edit
    @online_discount = AppSetting.get_int('online_payment_discount_percent', 0)
  end

  def update
    AppSetting.set('online_payment_discount_percent', params[:online_payment_discount_percent])
    redirect_to admin_settings_path, notice: "Settings updated successfully."
  rescue StandardError => e
    redirect_to admin_settings_path, alert: "Error updating settings: #{e.message}"
  end
end
