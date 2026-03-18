# frozen_string_literal: true

class CreateArtifacts < ActiveRecord::Migration[8.1]
  def change
    create_table :artifacts do |t|
      t.string :name, null: false
      t.string :artifact_type, null: false
      t.text :power
      t.boolean :corrupted, null: false, default: false
      t.references :character, null: true, foreign_key: true
      t.jsonb :stat_bonus, null: false, default: {}

      t.timestamps
    end

    add_index :artifacts, :artifact_type
    add_index :artifacts, :corrupted
    add_index :artifacts, :stat_bonus, using: :gin
  end
end
