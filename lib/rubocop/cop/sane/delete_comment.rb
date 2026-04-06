# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Detects comments that start with DELETE and flags them as severe issues.
      #
      # These comments mark code that should be removed. They serve as
      # actionable reminders during code review and CI.
      #
      # @example
      #   # bad
      #   # DELETE
      #   # DELETE this code after migration
      #   # DELETE: remove after v2
      #
      #   # good
      #   # TODO: clean up later
      #   # DELETED items are archived
      #
      class DeleteComment < Base
        COMMENT_PATTERN = /^#\s*DELETE\b/i
        MSG = "DELETE comment found — review and remove the marked code"

        def on_new_investigation
          return unless processed_source.valid_syntax?

          processed_source.comments.each do |comment|
            next unless comment.text.match?(COMMENT_PATTERN)

            add_offense(comment.source_range, severity: :error)
          end
        end
      end
    end
  end
end
