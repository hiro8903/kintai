class CreateMonthlyRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :monthly_requests do |t|
      t.integer :requester_id
      t.integer :requested_id
      t.date :request_month
      t.integer :state

      t.timestamps
    end
    add_index :monthly_requests, :requester_id
    add_index :monthly_requests, :requested_id
  end
end
