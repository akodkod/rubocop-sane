# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Prohibits calling methods directly after `end`.
      #
      # This cop detects method calls chained directly on blocks, conditionals,
      # and other structures that end with `end`. Such code is harder to read
      # and should be refactored to assign the result to a variable first.
      #
      # @example
      #   # bad
      #   if condition
      #     value
      #   end.foo
      #
      #   # bad
      #   if condition
      #     value
      #   end&.foo
      #
      #   # bad
      #   array.map do |item|
      #     transform(item)
      #   end.compact
      #
      #   # good
      #   result = if condition
      #     value
      #   end
      #   result.foo
      #
      #   # good
      #   result = array.map do |item|
      #     transform(item)
      #   end
      #   result.compact
      #
      class NoMethodCallAfterEnd < Base
        MSG = "Do not call methods directly after `end`."

        END_KEYWORD_NODES = [
          :if, :case, :case_match, :while, :until, :for,
          :kwbegin, :block, :numblock,
          :def, :defs, :class, :module, :sclass,
        ].freeze

        BLOCK_NODES = [:block, :numblock].freeze

        def on_send(node)
          check_method_call_after_end(node)
        end

        def on_csend(node)
          check_method_call_after_end(node)
        end

        private

        def check_method_call_after_end(node)
          receiver = node.receiver
          return unless receiver
          return unless ends_with_end_keyword?(receiver)

          add_offense(node.loc.dot || node.loc.selector)
        end

        def ends_with_end_keyword?(node)
          return false unless END_KEYWORD_NODES.include?(node.type)
          return !node.braces? if BLOCK_NODES.include?(node.type)

          true
        end
      end
    end
  end
end
