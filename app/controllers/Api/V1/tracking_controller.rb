class Api::V1::TrackingController < ApplicationController

  def track
    requests = JSON.parse(params["guias"])

    results = "Procesando..."
    render json: results

  end
end
