class Customer::NotificationsController < Customer::BaseController
  def index
    @notifications = current_user.notifications.recent
    @unread_count = current_user.notifications.unread.count
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.update!(read: true)

    respond_to do |format|
      format.html { redirect_back(fallback_location: customer_dashboard_path) }
      format.json { render json: { success: true } }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)
    redirect_back(fallback_location: customer_dashboard_path, notice: "All notifications marked as read.")
  end
end
