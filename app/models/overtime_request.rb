class OvertimeRequest < ApplicationRecord
  # belongs_to :overtime, polymorphic: true
  belongs_to :user
end
