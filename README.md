# README

**Prueba tecnica para la SkyDropX**

**De ante mano muchas  gracias por la atencion prestada, tiempo y oportunidad de evaluacion.**

**Daniel Andrade**

Acceso al front end: https://github.com/dandrade/front_end

Esta prueba tecnica fue desarrollada de la siguiente manera:

* La aplicacion esta pensada en facilitar la implementacion de un nuevo proveedor o carrier (Fedex, Estafeta, etc), esto lo desarrolle por medio de un poco de meta programming, para generar metodos y llamados a clases dinamicas, asi como tambien se implemento sidekiq para poder responder de manera asyncrona, una vez que sidekiq termina de procesar la informacion, esta se notifica por medio de ActionCable al cliente que hace la peticion, se hicieron pruebas con el set de datos proporcionado y la aplicacion funciona de manera rapida y asyncrona.

* La  aplicacion espera una peticion post al endpoint http://localhost:3001/api/v1/trackings con un arreglo de objetos de tracking_number y carrier

```
[
    {
        "tracking_number": "449044304137821",
        "carrier": "FEDEX"
    },
    {
        "tracking_number": "920241085725456",
        "carrier": "FEDEX"
    },
    {
        "tracking_number": "568838414941",
        "carrier": "FEDEX"
    },
    ...
    ...
 ]
    
```

**Pantallas del frontend https://github.com/dandrade/front_end**

![alt text](https://raw.githubusercontent.com/dandrade/backend/master/screen1.png)
![alt text](https://raw.githubusercontent.com/dandrade/backend/master/screen2.png)

Flujo desde controller:

```
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
```

```
# app/lib/start_check_tracking.rb
class StartCheckTracking
  CARRIERS = %w(fedex) # aqui definimos los carriers.
  
  def call
    send("check_#{carrier}")
  end

  def method_missing(method, *args, &block)
    puts "Carrier no implementado"
  end
  
  CARRIERS.each do |carrier|
    define_method "check_#{carrier}" do
      check_status_of_(@data)
    end
  end
  
  def check_status_of_(data)
    # Aqui tenemos que enviar a sidekiq
    Sidekiq::Client.push_bulk(
      'class' => CheckTrackingStatusWorker,
      'args' => [[data]]
    )
  end

```

* Como vemos utilizamos Sidekiq para las peticiones asyncronas, esto lo resuelve nuestra clase CheckTrackingStatusWorker, que es el worker que tenemos dentro de app/workers

```
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

```

* Una vez que se envia nuestra peticion a background, mandamos a llamar nuestra clase CheckStatus la cual se encargara de instanciar de manera  dinamica nuestro carrier o proveedor.

```
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

```

Como podemos ver en esta parte utilizamos Actioncable, esto para que por medio de sockets le respondamos a el frontend la respuesta a nuestras peticiones.



**Dentro de la carpeta app/lib definimos nuestro nuevo proveedor, en este caso fedex, aqui ya dentro de nuestro metodo call  podemos definir la logica propia de nuestro  carrier para la comuniicacion.**

```
# app/lib/fedex_provider.rb
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
    ....
    ....
    
```

**Requisitos**
* Ruby 2.6.0

* Redis
* Sidekiq
* PostgreSQL
* Fedex Gem (https://github.com/jazminschroeder/fedex)
* ActionCable

**Configuration**
  El archivo con las credenciales de Fedex, se encuentra en config/fedex_credentials.yml

**Instrucciones**

- Instalar redis instrucciones Mac(https://medium.com/@petehouston/install-and-config-redis-on-mac-os-x-via-homebrew-eb8df9a4f298)
```
bundle  install
```
- Especificar los datos de tu servidor redis en el archivo de configuracion de actioncable

```
  development:
    adapter: redis
    url: "redis://localhost:6379/1"
  
  production:
    adapter: redis
    url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
    channel_prefix: backend_production
```

  - Iniciar Sidekiq
  ```
  bundle exec sidekiq
  ```
  - Iniciar el servidor rails
  ```
  rails s --port  3001
  ```
