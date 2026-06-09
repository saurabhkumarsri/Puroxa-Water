class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  validates :name, :size, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :bottles_per_pack, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(active: true) }

  SIZES = %w[500ml 1L 2L 20L].freeze

  def self.ransackable_attributes(auth_object = nil)
    %w[name size active price]
  end

  def pack_display
    if bottles_per_pack > 1
      "1Pack(#{bottles_per_pack} bottles) — ₹#{price}"
    else
      "#{size} — ₹#{price} each"
    end
  end
end
