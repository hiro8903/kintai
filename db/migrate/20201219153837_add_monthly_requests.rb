class AddMonthlyRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :monthly_requests, :check, :integer, default: 0
  end
end
