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
      raise ValidationError.new(@location.errors.full_messages.join(", "))
    end
  end

  def update
    if @location.update(location_params)
      render_success({ location: @location })
    else
      raise ValidationError.new(@location.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @location.destroy
      render_success()
    else
      raise ActiveRecord::RecordNotDestroyed.new("Failed to delete location", @location)
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
