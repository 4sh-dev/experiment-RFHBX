# frozen_string_literal: true

module Api
  module V1
    class ChaosController < ApplicationController
      # POST /api/v1/chaos/kill_character
      # Kills a random non-fallen character for disaster recovery training.
      def kill_character
        character = Character.where.not(status: :fallen).order(Arel.sql("RANDOM()")).first

        unless character
          return render json: { error: "No eligible characters to kill" },
                        status: :unprocessable_entity
        end

        character.update!(status: :fallen)

        render json: {
          affected: {
            id: character.id,
            name: character.name,
            status: character.status
          }
        }
      end

      # POST /api/v1/chaos/fail_quest
      # Fails a random active quest and returns its members to idle.
      def fail_quest
        quest = Quest.where(status: :active).order(Arel.sql("RANDOM()")).first

        unless quest
          return render json: { error: "No active quests to fail" },
                        status: :unprocessable_entity
        end

        ActiveRecord::Base.transaction do
          quest.update!(status: :failed)
          quest.characters.where.not(status: :fallen).update_all(status: "idle")
        end

        render json: {
          affected: {
            id: quest.id,
            title: quest.title,
            status: quest.status
          }
        }
      end

      # POST /api/v1/chaos/destroy_artifact
      # Destroys a random artifact permanently.
      def destroy_artifact
        artifact = Artifact.order(Arel.sql("RANDOM()")).first

        unless artifact
          return render json: { error: "No artifacts to destroy" },
                        status: :unprocessable_entity
        end

        affected = { id: artifact.id, name: artifact.name, artifact_type: artifact.artifact_type }
        artifact.destroy!

        render json: { affected: affected }
      end

      # POST /api/v1/chaos/drain_xp
      # Drains 50% XP from all non-fallen characters (floor to 0).
      def drain_xp
        characters = Character.where.not(status: :fallen)

        if characters.none?
          return render json: { error: "No characters to drain" },
                        status: :unprocessable_entity
        end

        total_drained = 0

        ActiveRecord::Base.transaction do
          characters.each do |character|
            amount = (character.xp * 0.5).floor
            total_drained += amount
            character.update!(xp: character.xp - amount)
          end
        end

        render json: {
          characters_affected: characters.count,
          xp_drained: total_drained
        }
      end
    end
  end
end
