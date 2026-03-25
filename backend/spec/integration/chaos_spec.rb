# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Chaos", type: :request do
  path "/api/v1/chaos/kill_character" do
    post "Kill a random character" do
      tags "Chaos"
      operationId "chaosKillCharacter"
      produces "application/json"
      description "Kills a random non-fallen character for disaster recovery training. " \
                  "Returns 422 if no eligible characters exist."

      response "200", "character killed" do
        schema "$ref" => "#/components/schemas/ChaosKillResult"
        before { create(:character, status: :idle) }
        run_test!
      end

      response "422", "no eligible characters" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        run_test!
      end
    end
  end

  path "/api/v1/chaos/fail_quest" do
    post "Fail a random active quest" do
      tags "Chaos"
      operationId "chaosFailQuest"
      produces "application/json"
      description "Fails a random active quest and returns its non-fallen members to idle. " \
                  "Returns 422 if no active quests exist."

      response "200", "quest failed" do
        schema "$ref" => "#/components/schemas/ChaosFailQuestResult"
        before do
          character = create(:character, status: :on_quest)
          quest = create(:quest, status: :active)
          create(:quest_membership, quest: quest, character: character)
        end
        run_test!
      end

      response "422", "no active quests" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        run_test!
      end
    end
  end

  path "/api/v1/chaos/destroy_artifact" do
    post "Destroy a random artifact" do
      tags "Chaos"
      operationId "chaosDestroyArtifact"
      produces "application/json"
      description "Permanently destroys a random artifact. " \
                  "Returns 422 if no artifacts exist."

      response "200", "artifact destroyed" do
        schema "$ref" => "#/components/schemas/ChaosDestroyArtifactResult"
        before { create(:artifact) }
        run_test!
      end

      response "422", "no artifacts" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        run_test!
      end
    end
  end

  path "/api/v1/chaos/drain_xp" do
    post "Drain XP from all characters" do
      tags "Chaos"
      operationId "chaosDrainXp"
      produces "application/json"
      description "Drains 50% XP from all non-fallen characters. " \
                  "Returns 422 if no eligible characters exist."

      response "200", "XP drained" do
        schema "$ref" => "#/components/schemas/ChaosDrainXpResult"
        before { create(:character, status: :idle, xp: 1000) }
        run_test!
      end

      response "422", "no eligible characters" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        run_test!
      end
    end
  end
end
