# frozen_string_literal: true

class CreateQuests < ActiveRecord::Migration[8.1]
  def change
    create_table :quests do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.integer :danger_level, null: false, default: 1
      t.string :region
      t.decimal :progress, precision: 5, scale: 4, null: false, default: "0.0"
      t.decimal :success_chance, precision: 5, scale: 4
      t.string :quest_type, null: false, default: "campaign"
      t.integer :campaign_order
      t.integer :attempts, null: false, default: 0

      t.timestamps
    end

    add_index :quests, :status
    add_index :quests, :quest_type
    add_index :quests, :campaign_order
  end
end
