class AddTommorowToAttendanceEditRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :attendance_edit_requests, :tomorrow, :integer, default: 0
  end
end
