# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Enforces a minimum length for variable names.
      #
      # Short variable names can reduce code readability. This cop checks
      # local variable assignments and method/block parameters against a
      # configurable minimum length. Common names like loop counters can
      # be allowed via the `AllowedNames` option.
      #
      # @example MinLength: 3 (default)
      #   # bad
      #   a = 1
      #   ab = 2
      #   def foo(a, ab); end
      #
      #   # good
      #   age = 1
      #   amount = 2
      #   def foo(age, amount); end
      #
      # @example AllowedNames: ['i', 'j', 'k'] (default includes more)
      #   # good (allowed by default)
      #   items.each_with_index { |item, i| }
      #
      class VariableNameLength < Base
        MSG = "Variable name '%<name>s' is too short (minimum is %<min>s characters)."

        def on_lvasgn(node)
          name = node.name
          check_name(name, node)
        end

        alias on_arg on_lvasgn
        alias on_optarg on_lvasgn
        alias on_restarg on_lvasgn
        alias on_kwarg on_lvasgn
        alias on_kwoptarg on_lvasgn
        alias on_kwrestarg on_lvasgn
        alias on_blockarg on_lvasgn

        private

        def check_name(name, node)
          return unless name

          name_str = name.to_s
          return if name_str.start_with?("_")
          return if name_str.length >= min_length
          return if allowed_names.include?(name_str)

          add_offense(node, message: format(MSG, name: name_str, min: min_length))
        end

        def min_length
          @min_length ||= cop_config.fetch("MinLength", 3)
        end

        def allowed_names
          @allowed_names ||= cop_config.fetch("AllowedNames", []).map(&:to_s)
        end
      end
    end
  end
end
