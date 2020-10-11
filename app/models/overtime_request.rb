class OvertimeRequest < ApplicationRecord
  belongs_to :overtime, polymorphic: true
end
