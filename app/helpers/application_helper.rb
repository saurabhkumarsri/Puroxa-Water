module ApplicationHelper
  # Returns unread count + recent notifications for the current user.
  # The Notification model's `customer_id` is used as the recipient id,
  # so the same scope works for customers, vendors, and admins.
  def notification_bell_data(limit: 10)
    return { unread: 0, recent: [] } unless current_user

    recent = Notification.where(customer_id: current_user.id)
                         .includes(:order)
                         .order(created_at: :desc)
                         .limit(limit)
    # Count ALL unread for this user, not just within the limited recent set
    unread_count = Notification.where(customer_id: current_user.id, read: false).count
    { unread: unread_count, recent: recent }
  end
end
