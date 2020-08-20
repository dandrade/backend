require 'fedex'

class FedexProvider
  def initialize(args)
    # realizamos la conexion con fedex
    @company = Fedex::Shipment.new(FEDEX_CREDENTIALS)
    @args = args
  end

  # Metodo necesario como parte del contrato de los proveedores dinamicos
  # Aqui se define la implementacion de cada proveedor.
  def call
    tracking_number = args["tracking_number"]
    carrier = args["carrier"]
    shipment = Shipment.validates_existence_of_shipment(tracking_number, carrier)

    if shipment.nil?
      begin
        new_shipment = Shipment.generate_shipment(tracking_number, carrier)

        shipment_details = call_api(tracking_number)

        Shipment.generate_shipment_details(new_shipment, shipment_details)
      rescue => ex
        puts "Error -> #{ex.inspect}"
      end
    else
      puts "Ya me entregaron"
    end

  end

  private
  def company
    @company
  end

  def args
    @args
  end

  def call_api(tracking_number)
    response = company.track(:tracking_number => tracking_number).first
    events = response.events
    events.each do |event|
      puts "-------------"
      puts "Tracking number #{tracking_number} #Event #{event.inspect}"
      puts "-------------"
    end
    events
  end

end