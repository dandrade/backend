# CheckStatus nos permite mandar a llamar
# ya  de manera independiente la clase que va a implementar
# cada carrier por separado con su propia logica
# FedexProvider, UpsProvider, EstafetaProvider etc.
class CheckStatus

  def initialize(args, clazz)
    @args = args
    @clazz = clazz
  end

  def call
    message = "#{@clazz}Provider".constantize.new(@args).call
    if message.success?
      ActionCable.server.broadcast("trackings", details: message.payload)
    else
      ActionCable.server.broadcast("trackings", details: message.error)
    end

  end

end