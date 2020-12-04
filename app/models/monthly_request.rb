class MonthlyRequest < ApplicationRecord
  # belongs_to :user
  belongs_to :requester, class_name: "User"
  belongs_to :requested, class_name: "User"
  # validates :requester_id, presence: true
  # validates :requested_id, allow_nil: true
 
end
