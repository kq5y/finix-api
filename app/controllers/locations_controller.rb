class LocationsController < ApplicationController
  before_action :authenticate_request
  before_action :set_location, only: [ :update, :destroy ]

  def index
    @locations = @user.locations
    render_success({ items: @locations })
  end

  def create
    @location = @user.locations.new(location_params)
    if @location.save
      render_success({ location: @location }, :created)
    else
      render_error("Location not created")
    end
  end

  def update
    if @location.update(location_params)
      render_success({ location: @location })
    else
      render_error("Location not updated")
    end
  end

  def destroy
    if @location.destroy
      render_success()
    else
      render_error("Location not deleted")
    end
  end

  private

  def set_location
    @location = @user.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name)
  end
end
