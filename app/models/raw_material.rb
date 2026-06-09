class RawMaterial < ApplicationRecord
  CATEGORIES = %w[Empty_Bottle Cap Label Packaging Chemical Other].freeze

  validates :name, :category, :quantity, :unit, presence: true
  validates :quantity, :min_stock_level, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cost_per_unit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }

  def low_stock?
    min_stock_level.present? && quantity <= min_stock_level
  end

  def stock_badge_class
    if low_stock?
      "bg-red-100 text-red-800"
    elsif quantity <= (min_stock_level.to_i * 1.5)
      "bg-yellow-100 text-yellow-800"
    else
      "bg-green-100 text-green-800"
    end
  end
end
