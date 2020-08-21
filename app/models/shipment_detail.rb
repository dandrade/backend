class ShipmentDetail < ApplicationRecord
  enum status: [:created, :on_transit, :delivered, :exception]
  belongs_to :shipment
end
