class Shipment < ApplicationRecord
  has_many :shipment_details
  enum status: [:created, :on_transit, :delivered, :exception]

  def get_shipment_details
    if request_error.nil?
      try(:shipment_details)
    else
      request_error
    end
  end

   # Metodo para generar los detalles de los eventos de la guia
   def generate_shipment_details(shipment_details)
    shipment_details.each do |detail|
      # puts "detalle #{detail.type} #{detail.description} #{shipment.tracking_number}"
      self.shipment_details.create(
        description: detail[:description],
        status: detail[:status]
      )
    end
  end

  def update_errors_from_request(ex)
    self.update(request_error: ex)
  end

  private

  # validamos si previamente existe la guia en la base de datos
  # si no existe regresamos nil si existe regresamos el objecto, para
  # no haceer dos queries.
  def self.validates_existence_of_shipment(tracking_number, carrier)
    shipment = Shipment.includes(:shipment_details).where(tracking_number: tracking_number, carrier: carrier)
    return (shipment.empty?) ? nil : shipment[0]

  end


  # Creamos un metodo para generar la guia
  def self.generate_shipment(tracking_number, carrier)
    shipment = Shipment.new
    shipment.tracking_number = tracking_number
    shipment.carrier = carrier

    shipment if shipment.save

  end

end
