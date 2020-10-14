class CreateOvertimeRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :overtime_requests do |t|
      t.date :overtimed_on
      t.datetime :end_scheduled_at
      t.string :processing_content
      t.integer :state
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
