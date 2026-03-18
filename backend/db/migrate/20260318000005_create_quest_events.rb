# frozen_string_literal: true

class CreateQuestEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :quest_events do |t|
      t.references :quest, null: false, foreign_key: true
      t.string :event_type, null: false
      t.text :message
      t.jsonb :data, null: false, default: {}

      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :quest_events, :event_type
    add_index :quest_events, :created_at
    add_index :quest_events, :data, using: :gin
  end
end
