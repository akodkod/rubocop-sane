# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::EmptyLinesAroundMultilineBlock, :config do
  context "with multiline if/else" do
    it "registers offense for missing blank line before if" do
      expect_offense(<<~RUBY)
        work_for = data.work_done_for
        if data.present?
        ^^^^^^^^^^^^^^^^ Add empty line before multiline `if` block.
          creation_date = date1
        else
          creation_date = date2
        end
      RUBY

      expect_correction(<<~RUBY)
        work_for = data.work_done_for

        if data.present?
          creation_date = date1
        else
          creation_date = date2
        end
      RUBY
    end

    it "registers offense for missing blank line after if" do
      expect_offense(<<~RUBY)
        if data.present?
          creation_date = date1
        else
          creation_date = date2
        end
        ^^^ Add empty line after multiline `if` block.
        legal_start_date = date3
      RUBY

      expect_correction(<<~RUBY)
        if data.present?
          creation_date = date1
        else
          creation_date = date2
        end

        legal_start_date = date3
      RUBY
    end

    it "registers offense for missing blank lines before and after" do
      expect_offense(<<~RUBY)
        foo = bar
        if condition
        ^^^^^^^^^^^^ Add empty line before multiline `if` block.
          baz
        else
          qux
        end
        ^^^ Add empty line after multiline `if` block.
        quux = corge
      RUBY
    end
  end

  context "when at method boundaries" do
    it "does not require blank line at beginning of method" do
      expect_no_offenses(<<~RUBY)
        def foo
          if condition
            bar
          else
            baz
          end

          qux
        end
      RUBY
    end

    it "does not require blank line at end of method" do
      expect_no_offenses(<<~RUBY)
        def foo
          bar

          if condition
            baz
          else
            qux
          end
        end
      RUBY
    end

    it "does not require blank line when only child in method" do
      expect_no_offenses(<<~RUBY)
        def foo
          if condition
            bar
          else
            baz
          end
        end
      RUBY
    end
  end

  context "with ternary operators" do
    it "does not register offense for ternary" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result = condition ? 1 : 2
        baz = qux
      RUBY
    end
  end

  context "with modifier if" do
    it "does not register offense for modifier if" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        return if condition
        baz = qux
      RUBY
    end
  end

  context "with elsif" do
    it "does not register offense for elsif" do
      expect_no_offenses(<<~RUBY)
        foo = bar

        if condition1
          a
        elsif condition2
          b
        else
          c
        end

        baz = qux
      RUBY
    end
  end

  context "with case/when" do
    it "registers offense for missing blank lines around case" do
      expect_offense(<<~RUBY)
        foo = bar
        case value
        ^^^^^^^^^^ Add empty line before multiline `case` block.
        when :a
          handle_a
        when :b
          handle_b
        end
        ^^^ Add empty line after multiline `case` block.
        baz = qux
      RUBY
    end

    it "does not require blank line when only child" do
      expect_no_offenses(<<~RUBY)
        def foo
          case value
          when :a
            handle_a
          when :b
            handle_b
          end
        end
      RUBY
    end
  end

  context "with case/in (pattern matching)" do
    it "registers offense for missing blank lines around case match" do
      expect_offense(<<~RUBY)
        foo = bar
        case value
        ^^^^^^^^^^ Add empty line before multiline `case` block.
        in Integer
          handle_int
        in String
          handle_string
        end
        ^^^ Add empty line after multiline `case` block.
        baz = qux
      RUBY
    end
  end

  context "with do...end blocks" do
    it "registers offense for missing blank lines around block" do
      expect_offense(<<~RUBY)
        foo = bar
        items.each do |item|
        ^^^^^^^^^^^^^^^^^^^^ Add empty line before multiline `do...end` block.
          process(item)
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end

    it "does not require blank line when only child" do
      expect_no_offenses(<<~RUBY)
        def foo
          items.each do |item|
            process(item)
          end
        end
      RUBY
    end
  end

  context "with numblocks" do
    it "registers offense for missing blank lines around numblock" do
      expect_offense(<<~RUBY)
        foo = bar
        items.each do
        ^^^^^^^^^^^^^ Add empty line before multiline `do...end` block.
          process(_1)
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end
  end

  context "with chained blocks" do
    it "does not register offense for chained block" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        expect { dangerous_action }.to raise_error
        baz = qux
      RUBY
    end

    it "does not register offense for safe navigation chained block" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        items.map { |x| x.upcase }&.join
        baz = qux
      RUBY
    end
  end

  context "with lambda blocks" do
    it "does not register offense for lambda" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        my_proc = -> do
          something
        end
        baz = qux
      RUBY
    end

    it "does not register offense for stabby lambda" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        my_proc = -> {
          something
        }
        baz = qux
      RUBY
    end
  end

  context "when if is part of assignment" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result = if condition
                   1
                 else
                   2
                 end
        baz = qux
      RUBY
    end

    it "does not register offense for setter assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        obj.value = if condition
                      1
                    else
                      2
                    end
        baz = qux
      RUBY
    end

    it "does not register offense when part of array" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        arr = [if condition
                 1
               else
                 2
               end]
        baz = qux
      RUBY
    end

    it "does not register offense when part of hash" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        hash = { key: if condition
                        1
                      else
                        2
                      end }
        baz = qux
      RUBY
    end

    it "does not register offense when part of method arguments" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        method_call(if condition
                      1
                    else
                      2
                    end)
        baz = qux
      RUBY
    end
  end

  context "when block is part of assignment" do
    it "does not register offense for direct assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result = items.map do |item|
          item.upcase
        end
        baz = qux
      RUBY
    end

    it "does not register offense for setter assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        self.values = items.map do |item|
          item.upcase
        end
        baz = qux
      RUBY
    end

    it "does not register offense when in hash" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        hash = { key: items.map do |item|
                        item.upcase
                      end }
        baz = qux
      RUBY
    end

    it "does not register offense when in array" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        arr = [items.map do |item|
                 item.upcase
               end]
        baz = qux
      RUBY
    end
  end

  context "with comment before block" do
    it "does not register offense when comment precedes block" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        # This is a comment
        if condition
          baz
        else
          qux
        end
      RUBY
    end
  end

  context "with comment after block" do
    it "does not register offense when comment follows block" do
      expect_no_offenses(<<~RUBY)
        if condition
          baz
        else
          qux
        end
        # This is a comment
        foo = bar
      RUBY
    end
  end

  context "with desc + task pairing" do
    it "does not register offense for desc before task" do
      expect_no_offenses(<<~RUBY)
        desc "Some description"
        task :my_task do
          something
        end
      RUBY
    end

    it "still requires blank line after task block" do
      expect_offense(<<~RUBY)
        desc "Some description"
        task :my_task do
          something
        end
        ^^^ Add empty line after multiline `do...end` block.
        other_code
      RUBY
    end
  end

  context "when before rescue clause" do
    it "does not require blank line before rescue" do
      expect_no_offenses(<<~RUBY)
        begin
          if condition
            risky_operation
          else
            safe_operation
          end
        rescue => e
          handle_error(e)
        end
      RUBY
    end
  end

  context "with unless block" do
    it "registers offense for missing blank lines" do
      expect_offense(<<~RUBY)
        foo = bar
        unless condition
        ^^^^^^^^^^^^^^^^ Add empty line before multiline `unless` block.
          baz
        else
          qux
        end
        ^^^ Add empty line after multiline `unless` block.
        quux = corge
      RUBY
    end
  end

  context "with single-line blocks" do
    it "does not register offense for single-line if" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        if condition then baz else qux end
        quux = corge
      RUBY
    end

    it "does not register offense for single-line block" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        items.each { |item| process(item) }
        baz = qux
      RUBY
    end
  end

  context "when in if branch" do
    it "does not require blank line when only child in if branch" do
      expect_no_offenses(<<~RUBY)
        if outer_condition
          if inner_condition
            foo
          else
            bar
          end
        end
      RUBY
    end
  end

  context "when in else branch" do
    it "does not require blank line when only child in else branch" do
      expect_no_offenses(<<~RUBY)
        if outer_condition
          something
        else
          if inner_condition
            foo
          else
            bar
          end
        end
      RUBY
    end
  end

  context "when in when body" do
    it "does not require blank line when only child in when body" do
      expect_no_offenses(<<~RUBY)
        case value
        when :a
          if condition
            foo
          else
            bar
          end
        end
      RUBY
    end
  end

  context "when in case else" do
    it "does not require blank line when only child in case else" do
      expect_no_offenses(<<~RUBY)
        case value
        when :a
          something
        else
          if condition
            foo
          else
            bar
          end
        end
      RUBY
    end
  end

  context "when in resbody" do
    it "does not require blank line when only child in rescue body" do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue
          if condition
            foo
          else
            bar
          end
        end
      RUBY
    end
  end

  context "with class method definition" do
    it "does not require blank line when only child in defs" do
      expect_no_offenses(<<~RUBY)
        def self.foo
          if condition
            bar
          else
            baz
          end
        end
      RUBY
    end
  end

  context "when in block body" do
    it "does not require blank line when only child in block" do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          if condition
            process(item)
          else
            skip(item)
          end
        end
      RUBY
    end
  end

  context "with proper spacing" do
    it "does not register offense when blank lines exist" do
      expect_no_offenses(<<~RUBY)
        foo = bar

        if condition
          baz
        else
          qux
        end

        quux = corge
      RUBY
    end
  end

  context "with top-level code" do
    it "does not require blank line before first statement" do
      expect_no_offenses(<<~RUBY)
        if condition
          foo
        else
          bar
        end

        baz
      RUBY
    end

    it "does not require blank line after last statement" do
      expect_no_offenses(<<~RUBY)
        foo

        if condition
          bar
        else
          baz
        end
      RUBY
    end
  end

  context "when block has no location" do
    it "handles nodes without expression location gracefully" do
      expect_no_offenses(<<~RUBY)
        def foo
          if condition
            bar
          else
            baz
          end
        end
      RUBY
    end
  end

  context "with multiple consecutive blocks" do
    it "registers offense when blocks are not separated" do
      expect_offense(<<~RUBY)
        foo = bar

        if condition1
          a
        else
          b
        end
        ^^^ Add empty line after multiline `if` block.
        if condition2
        ^^^^^^^^^^^^^ Add empty line before multiline `if` block.
          c
        else
          d
        end

        baz = qux
      RUBY
    end
  end

  context "with block followed by expression" do
    it "requires blank line between block and expression" do
      expect_offense(<<~RUBY)
        items.each do |item|
          process(item)
          log(item)
        end
        ^^^ Add empty line after multiline `do...end` block.
        result = compute
      RUBY
    end
  end

  context "with parent nil check" do
    it "handles top-level case block" do
      expect_no_offenses(<<~RUBY)
        case value
        when :a
          foo
        when :b
          bar
        end
      RUBY
    end
  end

  context "with safe navigation on parent" do
    it "handles blocks with safe navigation" do
      expect_no_offenses(<<~RUBY)
        result = collection&.map do |item|
          transform(item)
        end
      RUBY
    end
  end
end
