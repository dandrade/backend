class TrackingsChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from 'trackings'
    puts "Conectado"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def receive(data)
    # note = Note.find(data["id"])
    # note.update!(text: data["text"])
    ActionCable.server.broadcast('trackings', data)
  end
end
