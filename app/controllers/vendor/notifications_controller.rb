class Vendor::NotificationsController < Vendor::BaseController
  def index
    @notifications = Notification.where(customer_id: current_user.id)
                                 .includes(:order)
                                 .order(created_at: :desc)
                                 .limit(50)
    # Count ALL unread, not just within the limited set
    @unread_count = Notification.where(customer_id: current_user.id, read: false).count
  end

  def mark_as_read
    @notification = Notification.where(customer_id: current_user.id).find(params[:id])
    @notification.update!(read: true)
    redirect_to vendor_notifications_path, notice: "Marked as read."
  end

  def mark_all_as_read
    Notification.where(customer_id: current_user.id, read: false).update_all(read: true)
    redirect_to vendor_notifications_path, notice: "All notifications marked as read."
  end

  def new
    @customers = User.where(role: User::ROLES[:customer]).order(:first_name)
  end

  def create
    title = params[:title]
    body = params[:body]
    customer_ids = params[:customer_ids]

    if customer_ids.include?("all")
      User.where(role: User::ROLES[:customer]).find_each do |customer|
        Notification.create!(customer: customer, title: "#{current_user.display_name}: #{title}", body: body)
      end
      redirect_to vendor_sent_notifications_path, notice: "Notification sent to all customers!"
    elsif customer_ids.present?
      User.where(id: customer_ids).find_each do |customer|
        Notification.create!(customer: customer, title: "#{current_user.display_name}: #{title}", body: body)
      end
      redirect_to vendor_sent_notifications_path, notice: "Notification sent to #{customer_ids.count} customer(s)!"
    else
      redirect_to vendor_new_notification_path, alert: "Please select at least one customer."
    end
  end

  def sent
    @notifications = Notification.includes(:customer).order(created_at: :desc).limit(200)
    @grouped = @notifications.group_by { |n| [n.title, n.body] }
    @grouped = @grouped.sort_by { |_, notifs| notifs.map(&:created_at).max }.reverse!
  end
end
