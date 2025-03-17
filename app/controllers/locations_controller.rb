class LocationsController < ApplicationController
  before_action :authenticate_request
  before_action :set_location, only: [ :show, :update, :destroy ]

  def index
    @locations = @user.locations

    # Sort
    @locations = @locations.apply_sort(params[:sort_key], params[:sort_order])

    # Paginate
    @locations = @locations.page(params[:page]).per(params[:page_size])

    render_success({ items: @locations, total_count: @locations.total_count })
  end

  def show
    render_success(@location)
  end

  def create
    @location = @user.locations.new(location_params)
    if @location.save
      render_success(@location, :created)
    else
      raise ValidationError.new(@location.errors.full_messages.join(", "))
    end
  end

  def update
    if @location.update(location_params)
      render_success(@location)
    else
      raise ValidationError.new(@location.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @location.discard
      render_success(nil)
    else
      raise Discard::RecordNotDiscarded.new("Failed to delete location", @location)
    end
  end

  private

  def set_location
    @location = @user.locations.find(params[:id])
  end

  def location_params
    params.expect(location: [ :name ])
  end
end
