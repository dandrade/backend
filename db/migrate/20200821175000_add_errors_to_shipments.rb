class AddErrorsToShipments < ActiveRecord::Migration[6.0]
  def change
    add_column :shipments, :request_error, :string
  end
end
