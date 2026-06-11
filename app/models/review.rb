class Review < ApplicationRecord
  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  belongs_to :order
  belongs_to :vendor, class_name: "User", foreign_key: "vendor_id"

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :order_id, uniqueness: true
end
