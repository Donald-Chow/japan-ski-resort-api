class Api::V1::ResortsController < Api::V1::BaseController
  before_action :set_resort, only: [:show]

  def index
    @resorts = policy_scope(Resort)
  end

  def show
  end

  private

  def set_resort
    @resort = Resort.find(params[:id])
    authorize @resort
  end
end
