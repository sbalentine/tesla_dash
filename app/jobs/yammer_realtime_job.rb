class YammerRealtimeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    channel_id = "Mjk6MTA3OjE2Mjk1ODkxMzU"
    YammerRealtime::Client.new.start(channel_id) do |message, references|
      if !sender_is_current_user?(message) &&
         private_message?(message) &&
         car_is_driving?(message)
        Yammer.create_message("Scott is driving right now and will respond shortly.", replied_to_id: message['id'])
      end
    end
  end

  private

  def sender_is_current_user?(message)
    message['sender_id'] == Yammer.current_user.body[:id]
  end

  def private_message?(message)
    message['direct_message']
  end

  def car_is_driving?
    return true if message['body']['plain'].include?("scottisdriving")
    TESLA_API.vehicles.first.drive_state['speed']
  end
end
