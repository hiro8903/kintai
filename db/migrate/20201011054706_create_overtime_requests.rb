class CreateOvertimeRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :overtime_requests do |t|
      t.datetime :end_scheduled_at
      t.string :processing_content
      t.integer :state
      t.references :overtime, polymorphic: true

      t.timestamps
    end
  end
end
