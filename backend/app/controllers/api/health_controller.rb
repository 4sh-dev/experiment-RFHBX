# frozen_string_literal: true

module Api
  class HealthController < ApplicationController
    # GET /api/health
    def show
      render json: {
        status: "ok",
        version: Rails.application.config.version,
        environment: Rails.env
      }, status: :ok
    end
  end
end
