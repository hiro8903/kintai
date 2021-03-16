class Base < ApplicationRecord
  validates :name, presence: true, length: { in: 1..20 }
  validates :number, presence: true
  validates :attendance_type, presence: true
end
