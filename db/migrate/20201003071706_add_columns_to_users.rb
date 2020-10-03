class AddColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :designated_work_start_time, :time, after: :basic_work_time, default: "09:00:00 +0900"
    add_column :users, :designated_work_end_time, :time, after: :designated_work_start_time, default: "18:00:00 +0900"
  end
end
