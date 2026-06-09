class Worker < ApplicationRecord
  has_one_attached :document
  has_one_attached :profile_picture

  IDENTITY_TYPES = %w[Aadhaar PAN Driving_License Voter_ID Passport].freeze
  STATUSES = %w[Active Inactive Resigned].freeze

  validates :name, :phone, :identity_type, :identity_number, presence: true
  validates :phone, format: { with: /\A[0-9]{10,12}\z/, message: "must be 10-12 digits" }
  validates :identity_type, inclusion: { in: IDENTITY_TYPES }
  validates :status, inclusion: { in: STATUSES }

  def identity_badge_class
    case identity_type
    when "Aadhaar" then "bg-blue-100 text-blue-800"
    when "PAN" then "bg-orange-100 text-orange-800"
    when "Driving_License" then "bg-purple-100 text-purple-800"
    when "Voter_ID" then "bg-green-100 text-green-800"
    when "Passport" then "bg-indigo-100 text-indigo-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  def status_badge_class
    case status
    when "Active" then "bg-green-100 text-green-800"
    when "Inactive" then "bg-yellow-100 text-yellow-800"
    when "Resigned" then "bg-red-100 text-red-800"
    else "bg-gray-100 text-gray-800"
    end
  end
end
