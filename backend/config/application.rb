# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module MordorsEdge
  class Application < Rails::Application
    config.load_defaults 8.1

    # API-only mode — no views, cookies, or sessions
    config.api_only = true

    # Application version (referenced by the health endpoint)
    config.version = "0.1.0"

    # Generator defaults: use RSpec, not MiniTest
    config.generators do |g|
      g.test_framework :rspec
      g.helper false
      g.assets false
      g.view_specs false
      g.helper_specs false
    end
  end
end
