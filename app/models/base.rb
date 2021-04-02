class Base < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { in: 1..20 }
  validates :number, presence: true, uniqueness: true
  validates :attendance_type, presence: true
end
