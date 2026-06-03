class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # NOTE: Do NOT change integer values — existing DB records depend on them
  ROLES = { admin: 0, customer: 1, vendor: 2, subadmin: 3 }.freeze

  validates :email, presence: true, uniqueness: true

  has_one :vendor_profile, class_name: "Vendor", dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, foreign_key: "customer_id", dependent: :destroy
  has_many :assigned_orders, class_name: "Order", foreign_key: "vendor_id", dependent: :nullify

  def role
    ROLES.key(read_attribute(:role))
  end

  def role=(value)
    write_attribute(:role, ROLES[value.to_sym])
  end

  def admin?
    role == :admin
  end

  def subadmin?
    role == :subadmin
  end

  def customer?
    role == :customer
  end

  def vendor?
    role == :vendor
  end

  def display_name
    first_name.presence || email.split("@").first
  end

  def default_address
    addresses.find_by(is_default: true) || addresses.first
  end
end
