class HomeController < ApplicationController
  def index
    @car = TESLA_API.vehicles.first
    @car.wake_up
    @drive_state = @car.drive_state
  end
end
