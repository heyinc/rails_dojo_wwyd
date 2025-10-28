class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.string :email
      t.string :name
      t.date :date
      t.time :time
      t.string :preferred_staff
      t.boolean :purchase_intention

      t.timestamps
    end
  end
end
