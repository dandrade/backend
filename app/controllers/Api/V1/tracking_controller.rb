class Api::V1::TrackingController < ApplicationController

  def track
    requests = JSON.parse(params["guias"])

    # recorremos todas las guias que el request trae
    requests.each do |request|
      # Enviamos la informacion de cada guia para iniciar
      # el proceso de checkado
      StartCheckTracking.new(request).call
    end

    results = "Procesando..."
    render json: results

  end
end
