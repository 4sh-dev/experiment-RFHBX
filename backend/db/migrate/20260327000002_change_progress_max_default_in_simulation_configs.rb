# frozen_string_literal: true

class ChangeProgressMaxDefaultInSimulationConfigs < ActiveRecord::Migration[8.1]
  def change
    change_column_default :simulation_configs, :progress_max, from: "0.1", to: "0.05"
  end
end
