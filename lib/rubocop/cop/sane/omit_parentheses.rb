# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Enforces omitting parentheses for specific methods.
      #
      # @example Methods configuration
      #   # .rubocop.yml
      #   # Sane/OmitParentheses:
      #   #   Methods:
      #   #     - render_record
      #   #     - Log.info
      #
      #   # bad
      #   render_record(record)
      #   Log.info("message")
      #
      #   # good
      #   render_record record
      #   Log.info "message"
      #
      class OmitParentheses < Base
        extend AutoCorrector

        MSG = "Omit parentheses for `%<method>s`."

        def on_send(node)
          return unless node.parenthesized?
          return if node.multiline?
          return if modifier_condition?(node)

          matched_method = find_matching_method(node)
          return unless matched_method

          message = format(MSG, method: matched_method)

          add_offense(node, message: message) do |corrector|
            if node.arguments.empty?
              corrector.remove(node.loc.begin)
            else
              corrector.replace(node.loc.begin, " ")
            end

            corrector.remove(node.loc.end)
          end
        end

        private

        def find_matching_method(node)
          methods.find { |method| matches?(node, method) }
        end

        def matches?(node, method_config)
          if method_config.include?(".")
            receiver_name, method_name = method_config.split(".", 2)

            node.receiver&.const_type? &&
              node.receiver.short_name.to_s == receiver_name &&
              node.method_name.to_s == method_name
          else
            node.method_name.to_s == method_config
          end
        end

        def modifier_condition?(node)
          parent = node.parent
          parent&.if_type? && parent&.modifier_form?
        end

        def methods
          @methods ||= Array(cop_config.fetch("Methods", []))
        end
      end
    end
  end
end
