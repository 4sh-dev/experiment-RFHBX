# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Chaos", type: :request do
  # ---------------------------------------------------------------------------
  # POST /api/v1/chaos/kill_character
  # ---------------------------------------------------------------------------
  describe "POST /api/v1/chaos/kill_character" do
    context "when eligible characters exist" do
      let!(:character) { create(:character, status: :idle) }

      it "returns HTTP 200" do
        post "/api/v1/chaos/kill_character"
        expect(response).to have_http_status(:ok)
      end

      it "sets the character status to fallen" do
        post "/api/v1/chaos/kill_character"
        expect(character.reload.status).to eq("fallen")
      end

      it "returns the affected character details" do
        post "/api/v1/chaos/kill_character"
        body = response.parsed_body
        expect(body["affected"]).to include("id", "name", "status")
        expect(body["affected"]["status"]).to eq("fallen")
      end
    end

    context "when an on_quest character exists" do
      let!(:character) { create(:character, status: :on_quest) }

      it "is eligible for killing" do
        post "/api/v1/chaos/kill_character"
        expect(character.reload.status).to eq("fallen")
      end
    end

    context "when all characters are already fallen" do
      let!(:character) { create(:character, status: :fallen) }

      it "returns HTTP 422" do
        post "/api/v1/chaos/kill_character"
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post "/api/v1/chaos/kill_character"
        expect(response.parsed_body["error"]).to be_present
      end
    end

    context "when no characters exist" do
      it "returns HTTP 422" do
        post "/api/v1/chaos/kill_character"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/chaos/fail_quest
  # ---------------------------------------------------------------------------
  describe "POST /api/v1/chaos/fail_quest" do
    context "when an active quest exists" do
      let!(:character) { create(:character, status: :on_quest) }
      let!(:quest) do
        q = create(:quest, status: :active)
        create(:quest_membership, quest: q, character: character)
        q
      end

      it "returns HTTP 200" do
        post "/api/v1/chaos/fail_quest"
        expect(response).to have_http_status(:ok)
      end

      it "sets the quest status to failed" do
        post "/api/v1/chaos/fail_quest"
        expect(quest.reload.status).to eq("failed")
      end

      it "returns the affected quest details" do
        post "/api/v1/chaos/fail_quest"
        body = response.parsed_body
        expect(body["affected"]).to include("id", "title", "status")
        expect(body["affected"]["status"]).to eq("failed")
      end

      it "returns non-fallen members to idle" do
        post "/api/v1/chaos/fail_quest"
        expect(character.reload.status).to eq("idle")
      end
    end

    context "when no active quests exist" do
      let!(:quest) { create(:quest, status: :pending) }

      it "returns HTTP 422" do
        post "/api/v1/chaos/fail_quest"
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post "/api/v1/chaos/fail_quest"
        expect(response.parsed_body["error"]).to be_present
      end
    end

    context "when fallen members are on the quest" do
      let!(:fallen_character) { create(:character, status: :fallen) }
      let!(:quest) do
        q = create(:quest, status: :active)
        create(:quest_membership, quest: q, character: fallen_character)
        q
      end

      it "does not change fallen character status" do
        post "/api/v1/chaos/fail_quest"
        expect(fallen_character.reload.status).to eq("fallen")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/chaos/destroy_artifact
  # ---------------------------------------------------------------------------
  describe "POST /api/v1/chaos/destroy_artifact" do
    context "when artifacts exist" do
      let!(:artifact) { create(:artifact) }

      it "returns HTTP 200" do
        post "/api/v1/chaos/destroy_artifact"
        expect(response).to have_http_status(:ok)
      end

      it "destroys one artifact" do
        expect { post "/api/v1/chaos/destroy_artifact" }
          .to change(Artifact, :count).by(-1)
      end

      it "returns the affected artifact details" do
        post "/api/v1/chaos/destroy_artifact"
        body = response.parsed_body
        expect(body["affected"]).to include("id", "name", "artifact_type")
      end
    end

    context "when no artifacts exist" do
      it "returns HTTP 422" do
        post "/api/v1/chaos/destroy_artifact"
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post "/api/v1/chaos/destroy_artifact"
        expect(response.parsed_body["error"]).to be_present
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/chaos/drain_xp
  # ---------------------------------------------------------------------------
  describe "POST /api/v1/chaos/drain_xp" do
    context "when non-fallen characters exist" do
      let!(:char1) { create(:character, status: :idle, xp: 1000) }
      let!(:char2) { create(:character, status: :on_quest, xp: 2000) }

      it "returns HTTP 200" do
        post "/api/v1/chaos/drain_xp"
        expect(response).to have_http_status(:ok)
      end

      it "drains 50% XP from each character" do
        post "/api/v1/chaos/drain_xp"
        expect(char1.reload.xp).to eq(500)
        expect(char2.reload.xp).to eq(1000)
      end

      it "returns characters_affected count" do
        post "/api/v1/chaos/drain_xp"
        expect(response.parsed_body["characters_affected"]).to eq(2)
      end

      it "returns total xp_drained" do
        post "/api/v1/chaos/drain_xp"
        expect(response.parsed_body["xp_drained"]).to eq(1500)
      end
    end

    context "when a character has zero XP" do
      let!(:char) { create(:character, status: :idle, xp: 0) }

      it "returns HTTP 200 without error" do
        post "/api/v1/chaos/drain_xp"
        expect(response).to have_http_status(:ok)
      end

      it "does not reduce XP below zero" do
        post "/api/v1/chaos/drain_xp"
        expect(char.reload.xp).to eq(0)
      end
    end

    context "when only fallen characters exist" do
      let!(:char) { create(:character, status: :fallen, xp: 1000) }

      it "returns HTTP 422" do
        post "/api/v1/chaos/drain_xp"
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post "/api/v1/chaos/drain_xp"
        expect(response.parsed_body["error"]).to be_present
      end

      it "does not drain fallen character XP" do
        post "/api/v1/chaos/drain_xp"
        expect(char.reload.xp).to eq(1000)
      end
    end

    context "when no characters exist" do
      it "returns HTTP 422" do
        post "/api/v1/chaos/drain_xp"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
