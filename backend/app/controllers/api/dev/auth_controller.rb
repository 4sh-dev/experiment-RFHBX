# frozen_string_literal: true

module Api
  module Dev
    # Dev-only authentication bypass endpoint.
    #
    # Issues a signed bypass token for the seeded dev user so engineers can
    # work locally without a running OIDC provider.
    #
    # POST /api/dev/auth
    # Response: { token: "...", user: { sub:, email:, name: } }
    #
    # This controller is only mounted in routes.rb when Rails.env.development?.
    # The additional runtime guard here is defence-in-depth.
    class AuthController < ApplicationController
      skip_before_action :authenticate_request!

      def create
        unless Rails.env.development? && ENV["DEV_AUTH_BYPASS"] == "true"
          render json: { error: "not found" }, status: :not_found
          return
        end

        token = DevAuthToken.generate
        render json: { token: token, user: DevAuthToken::DEV_CLAIMS }, status: :ok
      end
    end
  end
end
