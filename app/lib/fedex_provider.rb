require 'fedex'

class FedexProvider

  STATUS = {
    "OC" => 0,
    "PU" => 0,
    "AR" => 1,
    "DP" => 1
  }

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

    response = {}
    response[:tracking_number] = tracking_number

    shipment = Shipment.validates_existence_of_shipment(tracking_number, carrier)

    if shipment.nil?
      begin

        new_shipment = Shipment.generate_shipment(tracking_number, carrier)

        event_details = call_api(tracking_number)

        details = new_shipment.generate_shipment_details(event_details)

        response[:details] = new_shipment.get_shipment_details
        respomse[:status] = new_shipment.shipment_details.first.status
        OpenStruct.new({
          success?: true,
          payload: response
        })

      rescue => ex
        response[:error] = ex

        new_shipment.update_errors_from_request(ex)

        OpenStruct.new({
          success?: false,
          error: response
        })

      end


    else

      response[:details] = shipment.get_shipment_details
      OpenStruct.new({
        success?: true,
        payload: response
      })
    end

  end

  private

  def call_api(tracking_number)
    response = company.track(:tracking_number => tracking_number).first
    results = []

    response.events.each do |event|

      result = Hash.new
      result[:status] = status(event.type)
      result[:description] = event.description.to_s

      results << result
    end

    results
  end

  def company
    @company
  end

  def args
    @args
  end

  def status(s)
    STATUS[s]
  end

end