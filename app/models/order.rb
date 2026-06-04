class Order < ApplicationRecord
  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  belongs_to :vendor, class_name: "User", foreign_key: "vendor_id", optional: true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  STATUSES = %w[pending confirmed processing shipped delivered cancelled].freeze
  PAYMENT_STATUSES = %w[pending paid failed refunded].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :delivered, -> { where(status: "delivered") }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }

  def status_badge_class
    case status
    when "pending" then "bg-yellow-100 text-yellow-800"
    when "confirmed" then "bg-blue-100 text-blue-800"
    when "processing" then "bg-purple-100 text-purple-800"
    when "shipped" then "bg-indigo-100 text-indigo-800"
    when "delivered" then "bg-green-100 text-green-800"
    when "cancelled" then "bg-red-100 text-red-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  def payment_badge_class
    case payment_status
    when "paid" then "bg-green-100 text-green-800"
    when "failed" then "bg-red-100 text-red-800"
    when "refunded" then "bg-gray-100 text-gray-800"
    else "bg-yellow-100 text-yellow-800"
    end
  end

  def calculate_total!
    self.total_amount = order_items.sum(:total_price)
    save!
  end

  # Status convenience methods
  STATUSES.each do |s|
    define_method("#{s}?") { status == s }
  end

  # Payment status convenience methods
  PAYMENT_STATUSES.each do |s|
    define_method("payment_#{s}?") { payment_status == s }
  end
end
