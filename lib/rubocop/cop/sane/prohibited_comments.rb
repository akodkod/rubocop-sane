# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Detects comments that start with prohibited keywords.
      # Configure ProhibitedWords to replace the case-sensitive default list.
      # Configured words are flagged as warnings. An empty list disables matching.
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
        MSG = "%<word>s comment found — review and address the comment"

        def on_new_investigation
          return unless processed_source.valid_syntax?

          pattern = /^#\s*(#{Regexp.union(cop_config['ProhibitedWords'])})\b/
          processed_source.comments.each do |comment|
            match = comment.text.match(pattern)
            next unless match

            add_offense(comment.source_range, message: format(MSG, word: match[1]), severity: :warning)
          end
        end
      end
    end
  end
end
