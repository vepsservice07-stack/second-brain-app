module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      
      def login
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
          sign_in(user)
          render json: { user: { id: user.id, email: user.email } }
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end
      
      def logout
        sign_out(current_user) if current_user
        head :ok
      end
      
      def current_user_info
        if current_user
          render json: { user: { id: current_user.id, email: current_user.email } }
        else
          render json: { error: 'Not authenticated' }, status: :unauthorized
        end
      end
    end
  end
end
