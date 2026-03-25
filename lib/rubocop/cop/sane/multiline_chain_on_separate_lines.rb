# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Enforces that each method in a multiline chain starts on its own line
      # with a leading dot.
      #
      # @example
      #   # bad
      #   browser.find(
      #     "div[role='menu'] .v-list-item",
      #     text: "Confirmation Sheet",
      #     wait: 10,
      #   ).click
      #
      #   # good
      #   browser
      #     .find(
      #       "div[role='menu'] .v-list-item",
      #       text: "Confirmation Sheet",
      #       wait: 10,
      #     )
      #     .click
      #
      class MultilineChainOnSeparateLines < Base
        extend AutoCorrector

        MSG = "Place each method call in a multiline chain on a separate line with a leading dot."

        def on_send(node)
          check_chain(node)
        end

        alias on_csend on_send

        private

        def check_chain(node)
          return unless node.loc.dot
          return unless node.receiver

          receiver = node.receiver
          return unless chained_call?(receiver)

          return unless dot_on_receiver_last_line?(node, receiver)
          return unless multiline?(receiver) || (multiline?(node) && used_as_chain_receiver?(node))

          register_offense(node)
        end

        def chained_call?(receiver)
          receiver.send_type? || receiver.csend_type?
        end

        def multiline?(node)
          node.loc.first_line != node.loc.last_line
        end

        def dot_on_receiver_last_line?(node, receiver)
          node.loc.dot.line == receiver.loc.last_line
        end

        def used_as_chain_receiver?(node)
          parent = node.parent
          (parent&.send_type? || parent&.csend_type?) && parent.receiver == node
        end

        def register_offense(node)
          add_offense(node.loc.dot) do |corrector|
            indent = chain_root_column(node) + indentation_width
            range = node.loc.dot.with(begin_pos: node.receiver.source_range.end_pos)
            dot_text = node.loc.dot.source
            corrector.replace(range, "\n#{' ' * indent}#{dot_text}")
          end
        end

        def chain_root_column(node)
          current = node
          while (recv = current.receiver) && (recv.send_type? || recv.csend_type?)
            current = recv
          end
          current.receiver ? current.receiver.loc.column : current.loc.column
        end

        def indentation_width
          config.for_cop("Layout/IndentationWidth")["Width"] || 2
        end
      end
    end
  end
end
