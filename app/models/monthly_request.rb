class MonthlyRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :requested, class_name: "User"
  validates :requester_id, presence: true
  validates :requested_id, presence: true
end
