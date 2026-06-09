class Discount < ApplicationRecord
  DISCOUNT_TYPES = %w[percentage fixed].freeze

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_type, inclusion: { in: DISCOUNT_TYPES }
  validates :value, numericality: { greater_than: 0 }
  validates :min_order_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :usage_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true).where("expiry_date IS NULL OR expiry_date >= ?", Date.current) }

  def self.find_valid(code)
    discount = find_by(code: code.to_s.strip.upcase)
    return nil unless discount
    return nil unless discount.active?
    return nil if discount.expiry_date.present? && discount.expiry_date < Date.current
    return nil if discount.usage_limit.present? && discount.usage_count >= discount.usage_limit
    discount
  end

  def apply(total)
    return 0 if min_order_amount.present? && total < min_order_amount
    if percentage?
      (total * value / 100).round(2)
    else
      [value, total].min
    end
  end

  def percentage?
    discount_type == "percentage"
  end

  def fixed?
    discount_type == "fixed"
  end

  def display_value
    if percentage?
      "#{value}%"
    else
      "₹#{value}"
    end
  end
end
