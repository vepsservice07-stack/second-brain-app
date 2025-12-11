module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      respond_to :json
      
      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: e.message }, status: :not_found
      end
    end
  end
end
