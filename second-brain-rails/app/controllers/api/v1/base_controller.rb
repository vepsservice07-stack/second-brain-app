module Api
  module V1
    class BaseController < ActionController::API
      # Skip CSRF for API requests
      skip_before_action :verify_authenticity_token, raise: false
      
      # Standard JSON response
      def render_json(data, status: :ok)
        render json: data, status: status
      end
      
      def render_error(message, status: :unprocessable_entity)
        render json: { error: message }, status: status
      end
    end
  end
end
