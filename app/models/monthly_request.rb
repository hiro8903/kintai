class MonthlyRequest < ApplicationRecord
  # belongs_to :user
  belongs_to :requester, class_name: "User"
  belongs_to :requested, class_name: "User"
  with_options presence: true do
    validates :requester_id
    validates :requested_id
    validates :request_month
  end
end
