# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Detects configurable prohibited characters anywhere in comment text.
      # ProhibitedCharacters replaces the default list; an empty list allows all characters.
      #
      # @example ProhibitedCharacters: [";"] (default)
      #   # bad
      #   # Load the record; then update it
      #
      #   # good
      #   # Load the record, then update it
      class ProhibitedCommentCharacters < Base
        MSG = "Do not use %<character>s in comments. Stay a human."

        def on_new_investigation
          prohibited = cop_config["ProhibitedCharacters"]
          return if prohibited.empty?

          processed_source.comments.each do |comment|
            check_comment(comment, prohibited)
          end
        end

        private

        def check_comment(comment, prohibited)
          offset = comment.source_range.begin_pos
          comment.text.each_line do |line|
            check_line(comment, line, offset, prohibited) unless !comment.inline? && line.match?(/\A=(?:begin|end)\b/)
            offset += line.length
          end
        end

        def check_line(comment, line, offset, prohibited)
          line.each_char.with_index do |character, index|
            next if comment.inline? && index.zero?
            next unless prohibited.include?(character)

            range = comment.source_range.with(begin_pos: offset + index, end_pos: offset + index + 1)
            add_offense(range, message: format(MSG, character: character.inspect))
          end
        end
      end
    end
  end
end
