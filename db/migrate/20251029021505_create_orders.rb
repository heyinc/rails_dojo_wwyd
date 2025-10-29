class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :reservation, null: false, foreign_key: true
      t.string :email
      t.string :name
      t.string :product
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
