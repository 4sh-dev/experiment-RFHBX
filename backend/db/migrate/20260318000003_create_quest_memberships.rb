# frozen_string_literal: true

class CreateQuestMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :quest_memberships do |t|
      t.references :character, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end

    add_index :quest_memberships, %i[character_id quest_id], unique: true
  end
end
