# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Removes a comment's final period unless it contains an earlier period.
      # Consecutive standalone comments form a single comment block.
      # Inline comments and =begin/=end comments are checked independently.
      #
      # @example
      #   # bad
      #   # Explain this operation.
      #
      #   # good
      #   # Explain this operation
      #
      #   # good
      #   # First sentence.
      #   # Second sentence.
      class TrailingCommentPeriod < Base
        extend AutoCorrector

        MSG = "Remove the trailing period from a comment without earlier periods"

        def on_new_investigation
          blocks = processed_source.comments.chunk_while do |previous, current|
            standalone?(previous) && standalone?(current) &&
              current.loc.line == previous.loc.last_line + 1
          end
          blocks.each { |comments| check_comments(comments) }
        end

        private

        def standalone?(comment)
          comment.inline? && comment.source_range.source_line[0...comment.loc.column].strip.empty?
        end

        def check_comments(comments)
          texts = comments.map { |comment| comment_body(comment) }
          text = texts.join("\n").rstrip
          return unless text.end_with?(".") && text.count(".") == 1

          comment = comments.last
          offset = texts.last.rindex(".")
          period = period_range(comment, offset)
          add_offense(period) { |corrector| corrector.remove(period) }
        end

        def period_range(comment, offset)
          comment.source_range.with(
            begin_pos: comment.source_range.begin_pos + offset,
            end_pos: comment.source_range.begin_pos + offset + 1,
          )
        end

        def comment_body(comment)
          return comment.text if comment.inline?

          comment.text.sub(/^=end\b[^\n]*\n?\z/, "")
        end
      end
    end
  end
end
