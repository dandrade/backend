# Generamos nuestro worker para poder llamar a segundo plano
class CheckTrackingStatusWorker
  include Sidekiq::Worker
  # sidekiq_options retry: false

  def perform(args)
    carrier = args["carrier"].downcase.camelize
    # Check status nos va a dar el dinamismo
    # de implementar cada carrier en su propia clase
    CheckStatus.new(args, carrier).call
    GC.start # recogemos la basura
  end
end