# frozen_string_literal: true

module Types
  class RegionEnum < Types::BaseEnum
    description "Regions of Middle-earth where quests take place"

    value "SHIRE", "The peaceful home of hobbits", value: "Shire"
    value "RIVENDELL", "The elven sanctuary of Rivendell", value: "Rivendell"
    value "MORDOR", "The dark land of Mordor", value: "Mordor"
    value "ROHAN", "The horse kingdom of Rohan", value: "Rohan"
    value "GONDOR", "The realm of Gondor", value: "Gondor"
    value "MIRKWOOD", "The dark forest of Mirkwood", value: "Mirkwood"
  end
end
