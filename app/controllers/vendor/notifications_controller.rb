class Vendor::NotificationsController < Vendor::BaseController
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
      redirect_to new_vendor_notification_path, alert: "Please select at least one customer."
    end
  end

  def sent
    @notifications = Notification.includes(:customer).order(created_at: :desc).limit(200)
    @grouped = @notifications.group_by { |n| [n.title, n.body] }
    @grouped = @grouped.sort_by { |_, notifs| notifs.map(&:created_at).max }.reverse!
  end
end
