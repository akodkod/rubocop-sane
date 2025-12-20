# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # This cop enforces empty lines before and after multiline blocks
      # such as `if/else` and `case/when`.
      #
      # @example
      #   # bad
      #   work_for = data.work_done_for
      #   if data.present?
      #     creation_date = date1
      #   else
      #     creation_date = date2
      #   end
      #   legal_start_date = date3
      #
      #   # good
      #   work_for = data.work_done_for
      #
      #   if data.present?
      #     creation_date = date1
      #   else
      #     creation_date = date2
      #   end
      #
      #   legal_start_date = date3
      #
      #   # good - no blank line needed at beginning of method
      #   def foo
      #     if condition
      #       bar
      #     else
      #       baz
      #     end
      #
      #     qux
      #   end
      #
      #   # good - no blank line needed at end of method
      #   def foo
      #     bar
      #
      #     if condition
      #       baz
      #     else
      #       qux
      #     end
      #   end
      #
      class EmptyLinesAroundMultilineBlock < Base
        extend AutoCorrector

        MSG_BEFORE = "Add empty line before multiline `%<keyword>s` block."
        MSG_AFTER = "Add empty line after multiline `%<keyword>s` block."

        def on_if(node)
          return if node.ternary?
          return if node.modifier_form?
          return if node.elsif? # elsif is part of parent if, not a separate block
          return unless multiline?(node)
          return if part_of_expression?(node)

          check_empty_line_before(node)
          check_empty_line_after(node)
        end

        def part_of_expression?(node)
          parent = node.parent
          return false unless parent

          # Part of assignment: foo = if ... end
          return true if assignment_node?(parent)

          # Part of setter call: obj.foo = if ... end
          return true if parent.send_type? && parent.method_name.to_s.end_with?("=")

          # Part of method arguments: foo(if ... end)
          return true if parent.send_type? && parent.arguments.include?(node)

          # Part of array: [if ... end]
          return true if parent.array_type?

          # Part of hash value: { key: if ... end }
          return true if parent.pair_type?

          false
        end

        def on_case(node)
          return unless multiline?(node)

          check_empty_line_before(node)
          check_empty_line_after(node)
        end

        alias on_case_match on_case

        def on_block(node)
          return unless multiline?(node)
          return if method_chain_block?(node) # e.g., expect { ... }.to raise_error
          return if lambda_block?(node) # e.g., -> { ... } or -> do ... end
          return if block_in_collection?(node) # e.g., [items.map do...end] or {key: items.map do...end}

          assignment_parent = find_assignment_parent(node)
          if assignment_parent
            # Don't require blank line before assignment
            # But do check for blank line after the assignment
            check_empty_line_after_assignment(node, assignment_parent)
          else
            check_empty_line_before(node)
            check_empty_line_after(node)
          end
        end

        alias on_numblock on_block

        def lambda_block?(node)
          node.send_node&.lambda_literal?
        end

        def method_chain_block?(node)
          # Skip blocks that are part of a method chain
          # e.g., expect { ... }.to raise_error
          # e.g., foo.map { ... }&.join (csend is safe navigation &.)
          parent = node.parent
          (parent&.send_type? || parent&.csend_type?) && parent.receiver == node
        end

        def block_in_collection?(node)
          # Skip blocks that are in arrays or hashes (enclosed in a structure)
          parent = node.parent
          return false unless parent

          parent.array_type? || parent.pair_type?
        end

        def find_assignment_parent(node)
          parent = node.parent
          return nil unless parent

          # Direct assignment: foo = bar.map do...end
          return parent if assignment_node?(parent)

          # Assignment via setter: self.foo = bar.map do...end
          return parent if parent.send_type? && parent.method_name.to_s.end_with?("=")

          nil
        end

        def check_empty_line_after_assignment(block_node, assignment_node)
          return if last_child_of_parent?(assignment_node)
          return if followed_by_rescue?(assignment_node)

          next_sib = next_sibling(assignment_node)
          return unless next_sib
          return if next_sib.is_a?(Symbol)
          return if empty_line_between?(assignment_node, next_sib)
          return if comment_line_after?(block_node)

          keyword = block_keyword(block_node)

          add_offense(block_node.loc.end, message: format(MSG_AFTER, keyword: keyword)) do |corrector|
            corrector.insert_after(block_node, "\n")
          end
        end

        def assignment_node?(node)
          [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn, :masgn, :op_asgn, :or_asgn, :and_asgn].include?(node.type)
        end

        def preceded_by_paired_method?(node, prev_sibling)
          # Skip blank line requirement for idiomatic pairings like desc + task
          # Only applies to block nodes
          return false unless node.block_type? || node.numblock_type?
          return false unless prev_sibling&.send_type?
          return false unless node.send_node

          prev_method = prev_sibling.method_name
          current_method = node.send_node.method_name

          paired_methods?(prev_method, current_method)
        end

        def paired_methods?(prev_method, current_method)
          # desc + task is idiomatic in rake files
          prev_method == :desc && current_method == :task
        end

        def followed_by_rescue?(node)
          # Don't require blank line before rescue clause
          parent = node.parent
          return false unless parent

          # Check if parent is a rescue node and next sibling is a resbody
          if parent.rescue_type?
            siblings = parent.children
            index = siblings.index(node)
            return false unless index

            next_sib = siblings[index + 1]
            return next_sib&.resbody_type?
          end

          false
        end

        private

        def multiline?(node)
          node.loc.first_line != node.loc.last_line
        end

        def block_keyword(node)
          if node.if_type?
            node.keyword
          elsif node.case_type? || node.case_match_type?
            "case"
          elsif node.block_type? || node.numblock_type?
            "do...end"
          else
            "block"
          end
        end

        def check_empty_line_before(node)
          return if first_child_of_parent?(node)

          prev_sibling = previous_sibling(node)
          return unless prev_sibling
          return if prev_sibling.is_a?(Symbol) # Skip non-node siblings
          return if empty_line_between?(prev_sibling, node)
          return if comment_line_before?(node)
          return if preceded_by_paired_method?(node, prev_sibling)

          keyword = block_keyword(node)

          add_offense(node, message: format(MSG_BEFORE, keyword: keyword)) do |corrector|
            # Insert newline after the previous line's end
            corrector.insert_before(
              node.source_range.with(
                begin_pos: node.source_range.begin_pos - node.loc.column,
              ),
              "\n",
            )
          end
        end

        def check_empty_line_after(node)
          return if last_child_of_parent?(node)
          return if followed_by_rescue?(node)

          next_sibling = next_sibling(node)
          return unless next_sibling
          return if next_sibling.is_a?(Symbol) # Skip non-node siblings
          return if empty_line_between?(node, next_sibling)
          return if comment_line_after?(node)

          keyword = block_keyword(node)

          add_offense(node.loc.end, message: format(MSG_AFTER, keyword: keyword)) do |corrector|
            corrector.insert_after(node, "\n")
          end
        end

        def first_child_of_parent?(node)
          parent = node.parent
          return true unless parent

          # For block/def/class bodies, check within the body only
          return true if only_child_in_body?(node, parent)

          siblings = body_siblings(parent)
          siblings.first == node
        end

        def last_child_of_parent?(node)
          parent = node.parent
          return true unless parent

          # For block/def/class bodies, check within the body only
          return true if only_child_in_body?(node, parent)

          siblings = body_siblings(parent)
          siblings.last == node
        end

        def only_child_in_body?(node, parent)
          # When the node IS the body (not wrapped in begin), it's the only child
          return true if parent.type == :block && parent.body == node
          return true if parent.type == :def && parent.body == node
          return true if parent.type == :defs && parent.body == node
          return true if parent.type == :resbody && parent.body == node

          # For if/unless, check if node is the only thing in the if-branch or else-branch
          if parent.type == :if
            return true if parent.if_branch == node
            return true if parent.else_branch == node
          end

          # For case/when
          return true if parent.type == :when && parent.body == node
          return true if parent.type == :case && parent.else_branch == node

          false
        end

        def body_siblings(parent)
          # For begin nodes, all children are body siblings
          # For other nodes, filter to valid siblings
          parent.children.select { |c| valid_sibling?(c) }
        end

        def previous_sibling(node)
          parent = node.parent
          return unless parent

          siblings = parent.children
          index = siblings.index(node)
          return unless index&.positive?

          # Find previous node sibling (skip non-nodes and nodes without location)
          (index - 1).downto(0) do |i|
            sibling = siblings[i]
            return sibling if valid_sibling?(sibling)
          end

          nil
        end

        def next_sibling(node)
          parent = node.parent
          return unless parent

          siblings = parent.children
          index = siblings.index(node)
          return unless index

          # Find next node sibling (skip non-nodes and nodes without location)
          ((index + 1)...siblings.size).each do |i|
            sibling = siblings[i]
            return sibling if valid_sibling?(sibling)
          end

          nil
        end

        def valid_sibling?(sibling)
          sibling.is_a?(RuboCop::AST::Node) &&
            sibling.loc&.expression
        end

        def empty_line_between?(node1, node2)
          return true unless node1.loc&.expression && node2.loc&.expression

          line1 = node1.loc.last_line
          line2 = node2.loc.first_line

          # There's an empty line if there's more than 1 line between them
          (line2 - line1) > 1
        end

        def comment_line_before?(node)
          line_before = node.loc.first_line - 1
          return false if line_before < 1

          processed_source.comments.any? { |c| c.loc.line == line_before }
        end

        def comment_line_after?(node)
          line_after = node.loc.last_line + 1
          processed_source.comments.any? { |c| c.loc.line == line_after }
        end
      end
    end
  end
end
