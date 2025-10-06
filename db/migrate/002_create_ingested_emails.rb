class CreateIngestedEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :ingested_emails do |t|
      t.string :sender
      t.string :subject
      t.integer :status, default: 0, null: false
      t.text :error_message
      t.timestamps
    end

    add_index :ingested_emails, :status
    add_index :ingested_emails, :sender
  end
end
