# frozen_string_literal: true

require "lint_roller"

module RuboCop
  module Sane
    # A plugin that integrates RuboCop Sane with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "rubocop-sane",
          version: VERSION,
          homepage: "https://github.com/akodkod/rubocop-sane",
          description: "Sane RuboCop cops for modern Ruby development.",
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: RuboCop::Sane::CONFIG_DEFAULT,
        )
      end
    end
  end
end
