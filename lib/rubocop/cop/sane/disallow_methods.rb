# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Enforces method replacements and prohibitions.
      #
      # This cop checks for usage of specified methods and either suggests
      # replacements (with auto-correction) or prohibits usage entirely.
      #
      # @example ReplaceMethods configuration
      #   # .rubocop.yml
      #   # Sane/DisallowMethods:
      #   #   ReplaceMethods:
      #   #     deliver_now:
      #   #       with: deliver_later
      #   #       reason: "`deliver_later` sends the email via background job"
      #
      #   # bad
      #   UserMailer.welcome(user).deliver_now
      #
      #   # good
      #   UserMailer.welcome(user).deliver_later
      #
      # @example ProhibitedMethods configuration
      #   # .rubocop.yml
      #   # Sane/DisallowMethods:
      #   #   ProhibitedMethods:
      #   #     dangerous_method:
      #   #       reason: "This method is deprecated and unsafe"
      #
      #   # bad
      #   obj.dangerous_method
      #
      class DisallowMethods < Base
        extend AutoCorrector

        REPLACEABLE_METHOD_MSG = "You should use `%<with>s` instead of `%<method_name>s` because %<reason>s"
        PROHIBITED_METHOD_MSG = "You should not use `%<method_name>s` because %<reason>s"

        def on_send(node)
          method_name = node.method_name
          replaceable = replace_methods[method_name]
          prohibited = prohibited_methods[method_name]

          if replaceable
            handle_replaceable_method(node, method_name, replaceable)
          elsif prohibited
            handle_prohibited_method(node, method_name, prohibited)
          end
        end

        private

        def handle_replaceable_method(node, method_name, config)
          message = format(
            REPLACEABLE_METHOD_MSG,
            method_name: method_name,
            with: config["with"],
            reason: config["reason"],
          )

          add_offense(node, severity: :error, message: message) do |corrector|
            corrector.replace(node.loc.selector, config["with"])
          end
        end

        def handle_prohibited_method(node, method_name, config)
          message = format(
            PROHIBITED_METHOD_MSG,
            method_name: method_name,
            reason: config["reason"],
          )

          add_offense(node, severity: :error, message: message)
        end

        def replace_methods
          @replace_methods ||= build_method_hash(cop_config.fetch("ReplaceMethods", {}))
        end

        def prohibited_methods
          @prohibited_methods ||= build_method_hash(cop_config.fetch("ProhibitedMethods", {}))
        end

        def build_method_hash(config)
          return {} unless config.is_a?(Hash)

          config.transform_keys(&:to_sym)
        end

        def safe_autocorrect?
          false
        end
      end
    end
  end
end
