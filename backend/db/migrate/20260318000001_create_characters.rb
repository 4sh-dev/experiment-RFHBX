# frozen_string_literal: true

class CreateCharacters < ActiveRecord::Migration[8.1]
  def change
    create_table :characters do |t|
      t.string :name, null: false
      t.string :race, null: false
      t.string :realm
      t.string :title
      t.boolean :ring_bearer, null: false, default: false
      t.integer :level, null: false, default: 1
      t.integer :xp, null: false, default: 0
      t.integer :strength, null: false, default: 5
      t.integer :wisdom, null: false, default: 5
      t.integer :endurance, null: false, default: 5
      t.string :status, null: false, default: "idle"

      t.timestamps
    end

    add_index :characters, :name
    add_index :characters, :status
    add_index :characters, :race
  end
end
