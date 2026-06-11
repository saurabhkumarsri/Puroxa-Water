class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # NOTE: Do NOT change integer values — existing DB records depend on them
  ROLES = { admin: 0, customer: 1, vendor: 2, subadmin: 3 }.freeze

  validates :email, presence: true, uniqueness: true
  validates :contact, presence: true, uniqueness: true, format: { with: /\A[6-9]\d{9}\z/, message: "must be a valid 10-digit Indian mobile number" }, if: -> { contact.present? }

  # Allow login with email OR contact (mobile number)
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:email)
    if login.present?
      where(conditions).find_by("email = ? OR contact = ?", login, login)
    else
      where(conditions).first
    end
  end

  has_one :vendor_profile, class_name: "Vendor", dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, foreign_key: "customer_id", dependent: :destroy
  has_many :assigned_orders, class_name: "Order", foreign_key: "vendor_id", dependent: :nullify
  has_many :reviews, foreign_key: "customer_id", dependent: :destroy
  has_many :notifications, foreign_key: "customer_id", dependent: :destroy

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
    shop_name.presence || first_name.presence || email.split("@").first
  end

  def shop_display
    [shop_name, first_name].compact.join(" — ").presence || email.split("@").first
  end

  def default_address
    addresses.find_by(is_default: true) || addresses.first
  end

  def pending_amount
    orders.where(payment_status: "pending").sum(:total_amount).to_f
  end
end
