class CreateProcessingLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :processing_logs do |t|
      t.references :ingested_email, null: false, foreign_key: true
      t.string :parser
      t.integer :status, null: false
      t.jsonb :extracted_payload, default: {}
      t.text :error_message
      t.timestamps
    end

    add_index :processing_logs, :status
    add_index :processing_logs, :parser
    add_index :processing_logs, :created_at
  end
end
