class RemoveProductFromOrders < ActiveRecord::Migration[8.1]
  def change
    remove_column :orders, :product, :string
  end
end

