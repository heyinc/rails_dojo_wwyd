class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :stock, default: 0, null: false

      t.timestamps
    end
  end
end
