# frozen_string_literal: true

module RuboCop
  module Cop
    module Sane
      # Requires unique, populated model section headings in declaration order.
      # Other Title Case headings delimit sections without imposing an order.
      # ScopeMethodPatterns configures which class methods require Scopes.
      # This cop deliberately offers no autocorrection: declaration order can
      # affect class loading. It inspects direct declarations, not DSL wrappers.
      #
      # @example
      #   # bad
      #   class Job < ApplicationRecord
      #     belongs_to :company
      #   end
      #
      #   # good
      #   class Job < ApplicationRecord
      #     # Associations
      #     belongs_to :company
      #   end
      class ModelSections < Base
        SECTIONS = ["Includes", "Associations", "Validations", "Enumerables", "Scopes"].freeze
        MACROS = {
          Includes: [:include, :extend, :prepend],
          Associations: [:belongs_to, :has_one, :has_many, :has_and_belongs_to_many],
          Validations: [:validate, :validates, :validates!],
          Enumerables: [:enum, :array_enum],
          Scopes: [:scope, :default_scope],
        }.freeze
        HEADING = %r{\A# ([A-Z][a-zA-Z]*(?: (?:[A-Z][a-zA-Z]*|/|&))*)\z}

        def on_class(node)
          statements = statements_in(node.body).flat_map { |statement| expand_singleton(statement) }
          headings = headings_in(node, statements)
          events = (headings + statements).sort_by { |event| event.source_range.begin_pos }
          check_events(events, headings)
        end

        private

        def statements_in(body)
          return [] unless body

          body.begin_type? ? body.children : [body]
        end

        def expand_singleton(node)
          return [node] unless node.sclass_type? && node.children.first.self_type?

          statements_in(node.body)
        end

        def headings_in(node, statements)
          processed_source.comments.select do |comment|
            next false unless inside?(comment, node)
            next false unless processed_source.lines[comment.loc.line - 1].strip == comment.text
            next false unless HEADING.match?(comment.text)

            statements.none? { |statement| inside?(comment, statement) }
          end
        end

        def inside?(inner, outer)
          inner.source_range.begin_pos >= outer.source_range.begin_pos &&
            inner.source_range.end_pos <= outer.source_range.end_pos
        end

        def check_events(events, headings)
          current = nil
          populated = []
          highest = -1
          events.each do |event|
            if headings.include?(event)
              current = event
              next
            end

            section = section_for(event, current)
            next unless section

            populated << current if current&.text == "# #{section}"
            rank = SECTIONS.index(section)
            check_declaration(event, section, current, highest)
            highest = [highest, rank].max
          end
          check_headings(headings, populated)
        end

        def section_for(node, heading)
          node = declaration_node(node)
          return "Scopes" if class_method?(node) && scope_method?(node, heading)
          return unless model_macro?(node)

          return "Validations" if node.method_name.to_s.start_with?("validates_")

          MACROS.find { |_section, methods| methods.include?(node.method_name) }&.first&.to_s
        end

        def model_macro?(node)
          node.send_type? && (node.receiver.nil? || node.receiver.self_type?) && !singleton_body?(node)
        end

        def singleton_body?(node)
          node.each_ancestor(:sclass, :class).first&.sclass_type?
        end

        def declaration_node(node)
          node = node.if_branch || node.else_branch if node.if_type? && node.modifier_form?
          node.any_block_type? ? node.send_node : node
        end

        def class_method?(node)
          (node.defs_type? && node.receiver.self_type?) ||
            (node.def_type? && singleton_body?(node))
        end

        def scope_method?(node, heading)
          heading&.text == "# Scopes" ||
            cop_config.fetch("ScopeMethodPatterns", ["^with_", "^without_"]).any? do |pattern|
              Regexp.new(pattern).match?(node.method_name.to_s)
            end
        end

        def check_declaration(node, section, heading, highest)
          messages = []
          messages << "Place this declaration under `# #{section}`." unless heading&.text == "# #{section}"
          if SECTIONS.index(section) < highest
            messages << "Move this #{section} declaration before #{SECTIONS[highest]} declarations."
          end
          return if messages.empty?

          declaration = declaration_node(node)
          location = declaration.send_type? ? declaration.loc.selector : declaration.loc.name
          add_offense(location, message: messages.join(" "))
        end

        def check_headings(headings, populated)
          seen = []
          highest = -1
          headings.each do |heading|
            section = heading.text.delete_prefix("# ")
            rank = SECTIONS.index(section)
            next unless rank

            messages = []
            messages << "Duplicate `# #{section}` section." if seen.include?(section)
            messages << "Move `# #{section}` before `# #{SECTIONS[highest]}`." if rank < highest
            messages << "Remove empty `# #{section}` section." unless populated.include?(heading)
            add_offense(heading.source_range, message: messages.join(" ")) unless messages.empty?
            seen << section
            highest = [highest, rank].max
          end
        end
      end
    end
  end
end
