class AddItemIdToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :item, null: false, foreign_key: true
  end
end
