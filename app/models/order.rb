class Order < ApplicationRecord
  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  belongs_to :vendor, class_name: "User", foreign_key: "vendor_id", optional: true
  belongs_to :discount, optional: true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :review, dependent: :destroy
  has_many :notifications, dependent: :destroy

  STATUSES = %w[pending confirmed processing shipped delivered cancelled].freeze
  PAYMENT_STATUSES = %w[pending paid failed refunded].freeze
  PAYMENT_MODES = %w[cash online].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :payment_mode, inclusion: { in: PAYMENT_MODES }
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
    subtotal = order_items.sum(:total_price)

    # Online discount is calculated but NOT auto-applied to total_amount
    # It is only applied when payment is actually collected online.
    if online_discount_percent.to_i > 0
      self.online_discount_amount = (subtotal * online_discount_percent / 100.0).round(2)
    else
      self.online_discount_amount = 0.0
    end

    # total_amount = subtotal minus coupon discount only (online discount excluded)
    existing_discount = discounted_amount.to_f
    self.total_amount = [subtotal - existing_discount, 0].max
    save!
  end

  # Total if online discount were applied (shown on Pay page)
  def total_with_online_discount
    [total_amount - online_discount_amount.to_f, 0].max
  end

  def final_subtotal
    order_items.sum(:total_price)
  end

  # Apply online discount to total_amount (called when online payment is confirmed)
  def apply_online_discount!
    return unless payment_mode == "online"
    return if online_discount_percent.to_i == 0

    subtotal = final_subtotal
    self.online_discount_amount = (subtotal * online_discount_percent / 100.0).round(2)
    existing_discount = discounted_amount.to_f
    self.total_amount = [subtotal - existing_discount - online_discount_amount, 0].max
    save!
  end

  # Remove online discount (called when cash is collected for an online-mode order)
  def remove_online_discount!
    self.online_discount_amount = 0.0
    existing_discount = discounted_amount.to_f
    self.total_amount = [final_subtotal - existing_discount, 0].max
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
