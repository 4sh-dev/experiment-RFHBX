# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description "The mutation root of this schema"

    # Mutations will be added in Phase 3.4+ (Issue #23)
    has_no_fields(true)
  end
end
