class OvertimeRequest < ApplicationRecord
  # belongs_to :overtime, polymorphic: true
  belongs_to :attendance
end
