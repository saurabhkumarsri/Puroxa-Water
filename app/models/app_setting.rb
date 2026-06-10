class AppSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key)
    find_by(key: key.to_s)&.value
  end

  def self.get_int(key, default = 0)
    val = get(key)
    val.present? ? val.to_i : default
  end

  def self.set(key, value)
    record = find_or_initialize_by(key: key.to_s)
    record.update!(value: value.to_s)
    record
  end
end
