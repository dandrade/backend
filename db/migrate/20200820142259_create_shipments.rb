class CreateShipments < ActiveRecord::Migration[6.0]
  def change
    create_table :shipments do |t|
      t.string :tracking_number
      t.string :carrier
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :shipments, :tracking_number
  end
end
