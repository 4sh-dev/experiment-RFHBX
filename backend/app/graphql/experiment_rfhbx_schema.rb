# frozen_string_literal: true

class ExperimentRfhbxSchema < GraphQL::Schema
  query Types::QueryType
  mutation Types::MutationType

  # Prevent runaway queries
  max_depth 10
  max_complexity 300

  # Register all domain types in introspection even before root query/mutation
  # fields reference them (queries added in Phase 3.3+, mutations in 3.4+).
  # extra_types ensures types appear in `__schema { types }` introspection
  # regardless of whether they are reachable from the schema root.
  extra_types(
    Types::CharacterType,
    Types::QuestType,
    Types::ArtifactType,
    Types::QuestMembershipType,
    Types::SimulationConfigType,
    Types::CharacterStatusEnum,
    Types::RaceEnum,
    Types::QuestStatusEnum,
    Types::QuestTypeEnum,
    Types::RegionEnum,
    Types::SimulationModeEnum
  )

  # Use the default error handler
  rescue_from(ActiveRecord::RecordNotFound) do |err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, err.message
  end
end
