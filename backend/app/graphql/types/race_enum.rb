# frozen_string_literal: true

module Types
  class RaceEnum < Types::BaseEnum
    description "The race of a Middle-earth character"

    value "HOBBIT", "A hobbit from the Shire", value: "Hobbit"
    value "ELF", "An elf", value: "Elf"
    value "DWARF", "A dwarf", value: "Dwarf"
    value "MAN", "A man (human)", value: "Man"
    value "WIZARD", "An Istari wizard", value: "Wizard"
  end
end
