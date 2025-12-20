# frozen_string_literal: true

require "date"

module RuboCop
  module Cop
    module Sane
      # Detects TODO/NOTE/FIXME comments with dates that are in the past.
      #
      # This cop helps ensure that dated comments are reviewed when their
      # target date has passed.
      #
      # @example
      #   # bad (when date is in the past)
      #   # TODO[2024-01-01]: Remove this after migration
      #   # NOTE[2023-06-15]: Temporary workaround
      #   # FIXME[2024-03-01]: Fix this bug
      #
      #   # good (when date is in the future or today)
      #   # TODO[2025-12-31]: Remove this after migration
      #
      class OutdatedComments < Base
        COMMENT_PATTERN = /^#\s*(NOTE|TODO|FIXME)\[(\d{4}-\d{2}-\d{2})\]:/i
        MSG = "Review or remove this outdated comment dated %<date>s"

        def on_new_investigation
          return unless processed_source.valid_syntax?

          processed_source.comments.each do |comment|
            check_comment(comment)
          end
        end

        private

        def check_comment(comment)
          match = comment.text.match(COMMENT_PATTERN)
          return unless match

          date_str = match[2]
          parsed_date = Date.parse(date_str)

          return if parsed_date >= Date.today

          message = format(MSG, date: date_str)
          add_offense(comment.source_range, severity: :warning, message:)
        rescue Date::Error
          # Invalid date format, ignore
        end
      end
    end
  end
end
