# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # This cop enforces `assign_inside_condition` style like
      # `Style/ConditionalAssignment`, but allows ternary operators.
      #
      # @example
      #   # bad
      #   foo = if condition
      #     1
      #   else
      #     2
      #   end
      #
      #   # bad
      #   foo = case bar
      #   when :a then 1
      #   when :b then 2
      #   end
      #
      #   # good - assignment inside condition
      #   if condition
      #     foo = 1
      #   else
      #     foo = 2
      #   end
      #
      #   # good - ternary operators are allowed
      #   foo = condition ? 1 : 2
      #
      #   # good - multiline ternary operators are allowed
      #   foo = condition
      #     ? 1
      #     : 2
      #
      class ConditionalAssignmentAllowTernary < Base
        MSG = "Move the assignment inside the `%<keyword>s` branch."

        ASSIGNMENT_TYPES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn].freeze

        def on_lvasgn(node)
          check_assignment(node)
        end

        alias on_ivasgn on_lvasgn
        alias on_cvasgn on_lvasgn
        alias on_gvasgn on_lvasgn
        alias on_casgn on_lvasgn

        def on_masgn(node)
          check_assignment(node)
        end

        def on_op_asgn(node)
          check_assignment(node)
        end

        def on_or_asgn(node)
          check_assignment(node)
        end

        def on_and_asgn(node)
          check_assignment(node)
        end

        private

        def check_assignment(node)
          return unless assignment_to_conditional?(node)

          rhs = extract_rhs(node)
          return unless rhs

          keyword = rhs.if_type? ? rhs.keyword : "case"
          add_offense(node, message: format(MSG, keyword: keyword))
        end

        def assignment_to_conditional?(node)
          rhs = extract_rhs(node)
          return false unless rhs

          if rhs.if_type?
            # Allow ternary operators, only flag if/else blocks
            return false if rhs.ternary?

            rhs.else?
          else
            rhs.case_type?
          end
        end

        def extract_rhs(node)
          case node.type
          when :lvasgn, :ivasgn, :cvasgn, :gvasgn, :masgn, :or_asgn, :and_asgn
            node.children[1]
          when :casgn, :op_asgn
            node.children[2]
          end
        end
      end
    end
  end
end
