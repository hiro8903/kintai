class CreateOverTimeRequests < ActiveRecord::Migration[5.1]
  
  def change
    create_table :over_time_requests do |t|
      t.references :attendance, foreign_key: true
      t.integer :requester_id
      t.integer :requested_id
      t.datetime :end_scheduled_at
      t.string :content
      t.integer :state, default: 0

      t.timestamps
    end
    # add_index :over_time_request, :attendance_id
    # add_index :users, :requester_id
    # add_index :over_time_requests, :requested_id
  end

  # def change
  #   create_table :over_time_requests do |t|
  #     t.integer :attendance_id
  #     t.integer :requester_id
  #     t.integer :requested_id
  #     t.datetime :end_scheduled_at
  #     t.string :content
  #     t.integer :state, default: 0

  #     t.timestamps
  #   end
  #   add_index :over_time_requests, :attendance_id
  #   add_index :over_time_requests, :requester_id
  #   add_index :over_time_requests, :requested_id
  # end
end
