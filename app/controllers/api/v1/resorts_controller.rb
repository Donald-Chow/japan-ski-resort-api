class Api::V1::ResortsController < Api::V1::BaseController
  def index
    @resorts = policy_scope(Resort)
  end
end
