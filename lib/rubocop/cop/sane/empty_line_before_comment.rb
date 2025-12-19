# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Enforces an empty line before comments, except when the previous line
      # is the start of a block, class, method, or another comment.
      #
      # @example
      #   # bad
      #   foo = 1
      #   # This is a comment
      #   bar = 2
      #
      #   # good
      #   foo = 1
      #
      #   # This is a comment
      #   bar = 2
      #
      #   # good - after block/class/method start
      #   def foo
      #     # This comment doesn't need a blank line
      #     bar
      #   end
      #
      #   # good - consecutive comments
      #   # First comment
      #   # Second comment
      #
      #   # good - after control structure start
      #   if condition
      #     # Comment inside if
      #     do_something
      #   end
      #
      class EmptyLineBeforeComment < Base
        extend AutoCorrector

        MSG = "Add empty line before comment."

        def on_new_investigation
          processed_source.comments.each do |comment|
            check_comment(comment)
          end
        end

        private

        def check_comment(comment)
          return if inline_comment?(comment)
          return if first_line?(comment)
          return if preceded_by_empty_line?(comment)
          return if preceded_by_comment?(comment)
          return if preceded_by_block_start?(comment)

          add_offense(comment) do |corrector|
            corrector.insert_before(
              comment.source_range.with(
                begin_pos: comment.source_range.begin_pos - comment.source_range.column,
              ),
              "\n",
            )
          end
        end

        def inline_comment?(comment)
          # Check if there's code before the comment on the same line
          comment_line = processed_source.lines[comment.loc.line - 1]
          return false unless comment_line

          # Get the portion of the line before the comment
          before_comment = comment_line[0...comment.loc.column]
          before_comment && !before_comment.strip.empty?
        end

        def first_line?(comment)
          comment.loc.line == 1
        end

        def preceded_by_empty_line?(comment)
          prev_line_number = comment.loc.line - 1
          return true if prev_line_number < 1

          prev_line = processed_source.lines[prev_line_number - 1]
          prev_line.nil? || prev_line.strip.empty?
        end

        def preceded_by_comment?(comment)
          prev_line_number = comment.loc.line - 1
          return false if prev_line_number < 1

          processed_source.comments.any? { |c| c.loc.line == prev_line_number }
        end

        def preceded_by_block_start?(comment)
          prev_line_number = comment.loc.line - 1
          return false if prev_line_number < 1

          prev_line = processed_source.lines[prev_line_number - 1]
          return false unless prev_line

          block_start_pattern?(prev_line)
        end

        def block_start_pattern?(line)
          stripped = line.strip

          # Class, module, method definitions
          return true if stripped.match?(/\A(class|module|def)\s/)

          # Control structures
          return true if stripped.match?(/\A(if|unless|case|while|until|for|begin)\s/)
          return true if stripped == "begin"

          # Block openers (do or {)
          return true if stripped.end_with?(" do", " do |", "\tdo")
          return true if stripped.match?(/do\s*\|[^|]*\|\s*\z/)
          return true if stripped.end_with?("{")
          return true if stripped.match?(/\{\s*\|[^|]*\|\s*\z/)

          # Rescue/ensure/else/elsif/when inside blocks
          return true if stripped.match?(/\A(rescue|ensure|else|elsif|when)\b/)

          # Private/protected/public access modifiers
          return true if stripped.match?(/\A(private|protected|public)\s*\z/)

          false
        end
      end
    end
  end
end
