# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Enforces empty lines before and after multiline method calls,
      # including calls with multiline arguments and multiline method chains.
      #
      class EmptyLinesAroundMultilineCall < Base # rubocop:disable Metrics/ClassLength
        extend AutoCorrector

        MSG_BEFORE = "Add empty line before multiline method call."
        MSG_AFTER = "Add empty line after multiline method call."

        ASSIGNMENT_TYPES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn, :masgn, :op_asgn, :or_asgn, :and_asgn].freeze
        BODY_PARENT_TYPES = [:block, :numblock, :def, :defs, :resbody, :class, :module, :sclass].freeze
        CONTROL_FLOW_TYPES = [:return, :break, :next].freeze

        def on_send(node)
          check_call(node)
        end

        alias on_csend on_send

        private

        def check_call(node)
          return unless node.loc.first_line != node.loc.last_line
          return if excluded_call?(node)

          target = effective_target(node)
          check_empty_line_before(target)
          check_empty_line_after(node, target)
        end

        def excluded_call?(node)
          has_block?(node) || inner_chain_call?(node) || call_as_argument?(node) ||
            inside_collection?(node) || setter_call?(node) || inside_control_flow?(node) || skip_method?(node)
        end

        def has_block?(node)
          parent = node.parent
          (parent&.block_type? || parent&.numblock_type?) && node == parent.send_node
        end

        def inner_chain_call?(node)
          parent = node.parent
          (parent&.send_type? || parent&.csend_type?) && node == parent.receiver
        end

        def call_as_argument?(node)
          parent = node.parent
          return false unless parent&.send_type? || parent&.csend_type?

          parent.arguments.include?(node)
        end

        def inside_collection?(node)
          parent = node.parent
          parent && (parent.array_type? || parent.pair_type?)
        end

        def setter_call?(node)
          node.method_name.to_s.end_with?("=")
        end

        def inside_control_flow?(node)
          parent = node.parent
          parent && CONTROL_FLOW_TYPES.include?(parent.type)
        end

        def skip_method?(node)
          cop_config.fetch("SkipMethods", []).include?(node.method_name.to_s)
        end

        def preceded_by_sig?(node)
          prev_sib = previous_sibling(node)
          return false unless prev_sib.is_a?(RuboCop::AST::Node)

          (prev_sib.block_type? || prev_sib.numblock_type?) &&
            prev_sib.send_node&.method_name == :sig &&
            prev_sib.send_node&.receiver.nil?
        end

        def effective_target(node)
          parent = node.parent
          parent && ASSIGNMENT_TYPES.include?(parent.type) ? parent : node
        end

        def check_empty_line_before(node)
          return if first_child_of_parent?(node)
          return if preceded_by_sig?(node)

          prev_sib = previous_sibling(node)
          return if prev_sib.nil? || prev_sib.is_a?(Symbol)
          return if empty_line_between?(prev_sib, node)
          return if comment_line_before?(node)

          add_offense(node, message: MSG_BEFORE) do |corrector|
            corrector.insert_before(
              node.source_range.with(begin_pos: node.source_range.begin_pos - node.loc.column),
              "\n",
            )
          end
        end

        def check_empty_line_after(call_node, target)
          return if last_child_of_parent?(target) || followed_by_rescue?(target)

          next_sib = next_sibling(target)
          return if next_sib.nil? || next_sib.is_a?(Symbol)
          return if empty_line_between?(target, next_sib)
          return if rubocop_directive_after?(call_node)

          add_offense(after_offense_loc(call_node), message: MSG_AFTER) do |corrector|
            corrector.insert_after(target, "\n")
          end
        end

        def after_offense_loc(node)
          if node.loc.respond_to?(:end) && node.loc.end
            node.loc.end
          elsif node.loc.respond_to?(:selector) && node.loc.selector
            node.loc.selector
          else
            node
          end
        end

        def first_child_of_parent?(node)
          parent = node.parent
          return true unless parent
          return true if only_child_in_body?(node, parent)

          body_siblings(parent).first == node
        end

        def last_child_of_parent?(node)
          parent = node.parent
          return true unless parent
          return true if only_child_in_body?(node, parent)

          body_siblings(parent).last == node
        end

        def only_child_in_body?(node, parent)
          return true if BODY_PARENT_TYPES.include?(parent.type) && parent.body == node

          return true if (parent.type == :if) && (parent.if_branch == node || parent.else_branch == node)

          return true if parent.type == :when && parent.body == node
          return true if parent.type == :case && parent.else_branch == node

          false
        end

        def body_siblings(parent)
          parent.children.select { |c| c.is_a?(RuboCop::AST::Node) && c.loc&.expression }
        end

        def previous_sibling(node)
          parent = node.parent
          return unless parent

          siblings = parent.children
          index = siblings.index(node)
          return unless index&.positive?

          (index - 1).downto(0) do |i|
            sib = siblings[i]
            return sib if sib.is_a?(RuboCop::AST::Node) && sib.loc&.expression
          end
          nil
        end

        def next_sibling(node)
          parent = node.parent
          return unless parent

          siblings = parent.children
          index = siblings.index(node)
          return unless index

          ((index + 1)...siblings.size).each do |i|
            sib = siblings[i]
            return sib if sib.is_a?(RuboCop::AST::Node) && sib.loc&.expression
          end
          nil
        end

        def empty_line_between?(node1, node2)
          return true unless node1.loc&.expression && node2.loc&.expression

          line1 = node1.loc.last_line
          line2 = node2.loc.first_line
          ((line1 + 1)...line2).any? { |ln| processed_source.lines[ln - 1].strip.empty? }
        end

        def comment_line_before?(node)
          line_before = node.loc.first_line - 1
          return false if line_before < 1

          processed_source.comments.any? { |c| c.loc.line == line_before && standalone_comment?(c) }
        end

        def rubocop_directive_after?(node)
          line_after = node.loc.last_line + 1
          processed_source.comments.any? { |c| c.loc.line == line_after && c.text.start_with?("# rubocop:") }
        end

        def standalone_comment?(comment)
          processed_source.lines[comment.loc.line - 1].strip.start_with?("#")
        end

        def followed_by_rescue?(node)
          parent = node.parent
          return false unless parent&.rescue_type?

          siblings = parent.children
          index = siblings.index(node)
          return false unless index

          siblings[index + 1]&.resbody_type?
        end
      end
    end
  end
end
