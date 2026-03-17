# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health endpoint", type: :request do
  describe "GET /api/health" do
    before { get "/api/health" }

    it "returns HTTP 200" do
      expect(response).to have_http_status(:ok)
    end

    it "returns status 'ok'" do
      expect(response.parsed_body["status"]).to eq("ok")
    end

    it "returns the application version" do
      expect(response.parsed_body["version"]).to eq("0.1.0")
    end

    it "returns the current environment" do
      expect(response.parsed_body["environment"]).to eq("test")
    end
  end
end
