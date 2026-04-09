# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Detects comments that start with prohibited keywords.
      #
      # DELETE comments mark code that should be removed. They are flagged
      # as errors — actionable reminders during code review and CI.
      #
      # REMEMBER comments mark things that need attention. They are flagged
      # as warnings — lower priority than DELETE but still worth addressing.
      #
      # @example
      #   # bad
      #   # DELETE
      #   # DELETE this code after migration
      #   # DELETE: remove after v2
      #   # REMEMBER to update the docs
      #   # remember to notify the team
      #
      #   # good
      #   # Delete users
      #   # DELETED items are archived
      #   # Remember what user said
      #
      class ProhibitedComments < Base
        DELETE_PATTERN = /^#\s*(?:DELETE|delete)\b/
        REMEMBER_PATTERN = /^#\s*(?:REMEMBER|remember)\b/

        MSG_DELETE = "DELETE comment found — review and remove the marked code"
        MSG_REMEMBER = "REMEMBER comment found — review and address the reminder"

        def on_new_investigation
          return unless processed_source.valid_syntax?

          processed_source.comments.each do |comment|
            if comment.text.match?(DELETE_PATTERN)
              add_offense(comment.source_range, message: MSG_DELETE, severity: :error)
            elsif comment.text.match?(REMEMBER_PATTERN)
              add_offense(comment.source_range, message: MSG_REMEMBER, severity: :warning)
            end
          end
        end
      end
    end
  end
end
