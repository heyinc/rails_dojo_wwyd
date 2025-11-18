class AddPriceToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :price, :integer, null: false, default: 0
  end
end
