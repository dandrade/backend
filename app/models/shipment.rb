class Shipment < ApplicationRecord
  has_many :shipment_details
  enum status: [:created, :on_transit, :delivered, :exception]
end
