class RemoveInstructorFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :instruction, :string
    remove_column :attendances, :instructor, :string
  end
end
