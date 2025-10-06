class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :product_code
      t.string :subject
      t.timestamps
    end

    add_index :customers, :email
    add_index :customers, :phone
    add_index :customers, :product_code
  end
end
