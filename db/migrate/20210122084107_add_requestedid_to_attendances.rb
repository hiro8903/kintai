class AddRequestedidToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :requested_id, :integer
  end
end
