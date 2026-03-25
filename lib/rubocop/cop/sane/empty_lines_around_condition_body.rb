# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # This cop checks for empty lines at the beginning and end of
      # condition bodies (`if`, `elsif`, `else`, `unless`).
      #
      # @example
      #   # bad
      #   if condition
      #
      #     body
      #
      #   else
      #
      #     another_body
      #
      #   end
      #
      #   # good
      #   if condition
      #     body
      #   else
      #     another_body
      #   end
      #
      class EmptyLinesAroundConditionBody < Base
        extend AutoCorrector

        MSG_BEGINNING = "Remove empty line at the beginning of condition body"
        MSG_END = "Remove empty line at the end of condition body"

        def on_if(node)
          return if node.ternary?
          return if node.modifier_form?

          check_if_branch(node)
          check_else_branch(node)
        end

        private

        def check_if_branch(node)
          body = node.if_branch
          return unless body

          keyword_line = node.loc.keyword.line
          closing_line = end_line_for_if_branch(node)

          check_beginning(body, keyword_line)
          check_end(body, closing_line, closing_range_for_if_branch(node))
        end

        def check_else_branch(node)
          else_branch = node.else_branch
          return unless else_branch
          return unless node.loc.else

          # elsif is handled by its own on_if call
          return if else_branch.if_type? && else_branch.elsif?

          else_line = node.loc.else.line
          end_node = find_end_node(node)
          end_line = end_node.loc.end.line

          check_beginning(else_branch, else_line)
          check_end(else_branch, end_line, end_node.loc.end)
        end

        def end_line_for_if_branch(node)
          if node.else_branch
            if node.loc.else
              node.loc.else.line
            else
              node.else_branch.loc.keyword.line
            end
          else
            find_end_node(node).loc.end.line
          end
        end

        def closing_range_for_if_branch(node)
          if node.else_branch
            node.loc.else || node.else_branch.loc.keyword
          else
            find_end_node(node).loc.end
          end
        end

        def find_end_node(node)
          current = node
          current = current.parent while current.parent&.if_type? && current.elsif?
          current
        end

        def check_beginning(body, keyword_line)
          first_line = body.loc.first_line
          return unless first_line > keyword_line + 1
          return unless blank_lines_between?(keyword_line, first_line)

          range = first_body_expression(body).source_range
          add_offense(range, message: MSG_BEGINNING) do |corrector|
            remove_blank_lines(corrector, keyword_line, first_line)
          end
        end

        def check_end(body, closing_line, closing_range)
          last_line = body.loc.last_line
          return unless closing_line > last_line + 1
          return unless blank_lines_between?(last_line, closing_line)

          add_offense(closing_range, message: MSG_END) do |corrector|
            remove_blank_lines(corrector, last_line, closing_line)
          end
        end

        def first_body_expression(body)
          body.begin_type? ? body.children.first : body
        end

        def blank_lines_between?(start_line, end_line)
          ((start_line + 1)...end_line).any? { |line_num| blank_line?(line_num) }
        end

        def blank_line?(line_num)
          processed_source.lines[line_num - 1].strip.empty?
        end

        def remove_blank_lines(corrector, start_line, end_line)
          buffer = processed_source.buffer

          ((start_line + 1)...end_line).each do |line_num|
            next unless blank_line?(line_num)

            line_begin = buffer.line_range(line_num).begin_pos
            next_line_begin =
              if line_num < processed_source.lines.size
                buffer.line_range(line_num + 1).begin_pos
              else
                buffer.line_range(line_num).end_pos
              end

            corrector.remove(Parser::Source::Range.new(buffer, line_begin, next_line_begin))
          end
        end
      end
    end
  end
end
