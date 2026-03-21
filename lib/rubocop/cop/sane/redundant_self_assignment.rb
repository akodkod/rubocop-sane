# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Detects redundant `||=` patterns where the RHS repeats the
      # assignment to the same target.
      #
      # @example
      #   # bad
      #   self.browser ||= self.browser = Capybara::Session.new(:cuprite)
      #
      #   # good
      #   self.browser ||= Capybara::Session.new(:cuprite)
      #
      #   # bad
      #   @foo ||= @foo = compute_value
      #
      #   # good
      #   @foo ||= compute_value
      #
      class RedundantSelfAssignment < Base
        extend AutoCorrector

        MSG = "Redundant assignment in `||=`. Use `%<lhs>s ||= %<value>s` instead."

        VARIABLE_ASGN_TYPES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn].freeze

        def on_or_asgn(node)
          lhs, rhs = *node
          return unless redundant_rhs?(lhs, rhs)

          value_node = rhs.children.last
          message = format(MSG, lhs: lhs.source, value: value_node.source)

          add_offense(rhs, message: message) do |corrector|
            corrector.replace(rhs, value_node.source)
          end
        end

        private

        def redundant_rhs?(lhs, rhs)
          if VARIABLE_ASGN_TYPES.include?(lhs.type)
            redundant_variable_assignment?(lhs, rhs)
          elsif lhs.type == :casgn
            redundant_const_assignment?(lhs, rhs)
          elsif lhs.send_type?
            redundant_method_assignment?(lhs, rhs)
          else
            false
          end
        end

        def redundant_variable_assignment?(lhs, rhs)
          rhs.type == lhs.type &&
            rhs.children[0] == lhs.children[0]
        end

        def redundant_const_assignment?(lhs, rhs)
          rhs.type == :casgn &&
            rhs.children[0] == lhs.children[0] &&
            rhs.children[1] == lhs.children[1]
        end

        def redundant_method_assignment?(lhs, rhs)
          rhs.send_type? &&
            rhs.receiver == lhs.receiver &&
            rhs.method_name == :"#{lhs.method_name}="
        end
      end
    end
  end
end
