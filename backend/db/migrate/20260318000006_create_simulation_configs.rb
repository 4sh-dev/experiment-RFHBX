# frozen_string_literal: true

class CreateSimulationConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :simulation_configs do |t|
      t.string :mode, null: false, default: "campaign"
      t.boolean :running, null: false, default: false
      t.integer :tick_interval_seconds, null: false, default: 60
      t.decimal :progress_min, precision: 6, scale: 4, null: false, default: "0.01"
      t.decimal :progress_max, precision: 6, scale: 4, null: false, default: "0.1"
      t.integer :campaign_position, null: false, default: 0

      t.timestamps
    end
  end
end
