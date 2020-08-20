# Definimos una clase la cual por medio de meta programing, nos permite generar metodos dinamicos
# check_fedex check_ups etc
class StartCheckTracking
  CARRIERS = %w(fedex)

  def initialize(data)
    @data = data
  end

  def call
    send("check_#{carrier}")
  end

  def method_missing(method, *args, &block)
    puts "Carrier no implementado"
  end

  private

  def carrier
    @data["carrier"].downcase
  end

  CARRIERS.each do |carrier|
    define_method "check_#{carrier}" do
      clazz = carrier.camelize
      check_status_of_(@data, clazz: clazz)
    end
  end

  def check_status_of_(data, clazz:clazz)
    # Aqui tenemos que enviar a sidekiq

  end
end