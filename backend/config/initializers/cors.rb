# frozen_string_literal: true

# CORS configuration for the frontend dev server and any configured origins.
# Set the CORS_ORIGINS environment variable (comma-separated) to override.
# Default allows the Vite dev server at http://localhost:5173.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:5173").split(",").map(&:strip)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: ["Authorization"]
  end
end
