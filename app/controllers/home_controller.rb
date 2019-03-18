class HomeController < ApplicationController
  def index
    tesla_api = TeslaApi::Client.new(ENV['TESLA_ACCOUNT_EMAIL'],
                                     ENV['TESLA_CLIENT_ID'],
                                     ENV['TESLA_CLIENT_SECRET'])
    tesla_api.token = ENV['TESLA_ACCOUNT_TOKEN']
    model_3 = tesla_api.vehicles.first
    model_3.wake_up
    @charge_state = model_3.charge_state
  end
end
