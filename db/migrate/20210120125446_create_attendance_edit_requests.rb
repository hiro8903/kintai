class CreateAttendanceEditRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_edit_requests do |t|
      t.references :attendance, foreign_key: true
      t.integer :requester_id
      t.integer :requested_id
      t.datetime :started_at
      t.datetime :finished_at
      t.string :note
      t.integer :state, default: 0

      t.timestamps
    end
    add_index :attendance_edit_requests, :requester_id
    add_index :attendance_edit_requests, :requested_id
  end
end
