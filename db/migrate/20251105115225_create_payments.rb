class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :payment_id, null: false
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
