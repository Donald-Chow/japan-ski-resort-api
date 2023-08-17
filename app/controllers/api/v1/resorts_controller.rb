class Api::V1::ResortsController < Api::V1::BaseController
  acts_as_token_authentication_handler_for User, except: %i[index show]
  before_action :set_resort, only: %i[show update]

  def index
    @resorts = policy_scope(Resort)
    return unless params['search']

    @resorts = Resort.search_by_name_and_location(params['search'])
  end

  def show
  end

  def create
    @resort = Resort.new(resort_params)
    @resort.user = current_user
    authorize @resort
    if @resort.save
      render :show, status: :created
    else
      render_error
    end
  end

  def update
    if @resort.update(resort_params)
      render :show
    else
      render_error
    end
  end

  def destroy
    @resort.destroy
    head :no_content
  end

  private

  def set_resort
    @resort = Resort.find(params[:id])
    authorize @resort
  end

  def resort_params
    params.require(:resort).permit(:name, :prefecture, :town, :address, :trail_length, :longest_trial, :skiable_terrain,
                                   :number_of_trails, :vertical_drop, :lift, :gondola, :base_altitude,
                                   :highest_altitude, :steepest_gradient, :difficulty_green, :difficulty_red,
                                   :difficulty_black, :terrain_park)
  end

  def render_error
    render json: { errors: @resort.errors.full_messages }, status: :unprocessable_entity
  end
end
