class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = { admin: 0, customer: 1, vendor: 2 }.freeze

  def role
    ROLES.key(read_attribute(:role))
  end

  def role=(value)
    write_attribute(:role, ROLES[value.to_sym])
  end

  def admin?
    role == :admin.to_s
  end

  def customer?
    role == :customer.to_s
  end

  def vendor?
    role == :vendor.to_s
  end
end
