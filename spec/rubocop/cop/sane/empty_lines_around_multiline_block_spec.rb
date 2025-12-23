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

  context "with Sorbet sig blocks" do
    it "does not require blank line after sig block" do
      expect_no_offenses(<<~RUBY)
        foo = bar

        sig do
          params(x: Integer)
            .returns(String)
        end
        def foo(x)
          x.to_s
        end
      RUBY
    end

    it "does not require blank line after sig with type_parameters" do
      expect_no_offenses(<<~RUBY)
        something

        sig do
          type_parameters(:T)
            .params(struct: T.class_of(T::Struct))
            .returns(T.type_parameter(:T))
        end
        def parse_params(struct)
          struct.deserialize_from(json: params.to_unsafe_h)
        end
      RUBY
    end

    it "requires blank line before sig block" do
      expect_offense(<<~RUBY)
        foo = bar
        sig do
        ^^^^^^ Add empty line before multiline `do...end` block.
          params(x: Integer)
            .returns(String)
        end
        def foo(x)
          x.to_s
        end
      RUBY

      expect_correction(<<~RUBY)
        foo = bar

        sig do
          params(x: Integer)
            .returns(String)
        end
        def foo(x)
          x.to_s
        end
      RUBY
    end

    it "does not require blank line before sig at start of class body" do
      expect_no_offenses(<<~RUBY)
        class MyService
          sig do
            params(name: String)
              .returns(User)
          end
          def create_user(name)
            User.create(name: name)
          end
        end
      RUBY
    end

    it "requires blank line before sig after other code in class" do
      expect_offense(<<~RUBY)
        class MyService
          some_code
          sig do
          ^^^^^^ Add empty line before multiline `do...end` block.
            params(name: String)
              .returns(User)
          end
          def create_user(name)
            User.create(name: name)
          end
        end
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
    it "registers offense for direct assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        result = items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY

      expect_correction(<<~RUBY)
        foo = bar
        result = items.map do |item|
          item.upcase
        end

        baz = qux
      RUBY
    end

    it "registers offense for setter assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        self.values = items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY

      expect_correction(<<~RUBY)
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

    it "registers offense for each_with_object block followed by code" do
      expect_offense(<<~RUBY)
        messages = errors.each_with_object([]) do |(key, values), arr|
          if key == :base
            arr << values.join(", ")
          else
            arr << key.to_s
          end
        end
        ^^^ Add empty line after multiline `do...end` block.
        messages.join(". ")
      RUBY

      expect_correction(<<~RUBY)
        messages = errors.each_with_object([]) do |(key, values), arr|
          if key == :base
            arr << values.join(", ")
          else
            arr << key.to_s
          end
        end

        messages.join(". ")
      RUBY
    end

    it "does not register offense when assignment block is last expression" do
      expect_no_offenses(<<~RUBY)
        def foo
          messages = errors.each_with_object([]) do |(key, values), arr|
            arr << key.to_s
          end
        end
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

  context "with operator assignment blocks" do
    it "registers offense for ||= assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        result ||= items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end

    it "registers offense for &&= assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        result &&= items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end

    it "registers offense for += assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        result += items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end
  end

  context "with instance/class/global variable assignment" do
    it "registers offense for instance variable assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        @result = items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end

    it "registers offense for class variable assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        @@result = items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end

    it "registers offense for global variable assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        $result = items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end

    it "registers offense for constant assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        RESULT = items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end

    it "registers offense for multiple assignment followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        a, b = items.map do |item|
          item.upcase
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end
  end

  context "with if assignment variants" do
    it "does not register offense for instance variable if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        @result = if condition
                    1
                  else
                    2
                  end
        baz = qux
      RUBY
    end

    it "does not register offense for class variable if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        @@result = if condition
                     1
                   else
                     2
                   end
        baz = qux
      RUBY
    end

    it "does not register offense for global variable if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        $result = if condition
                    1
                  else
                    2
                  end
        baz = qux
      RUBY
    end

    it "does not register offense for constant if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        RESULT = if condition
                   1
                 else
                   2
                 end
        baz = qux
      RUBY
    end

    it "does not register offense for multiple if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        a, b = if condition
                 [1, 2]
               else
                 [3, 4]
               end
        baz = qux
      RUBY
    end

    it "does not register offense for ||= if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result ||= if condition
                     1
                   else
                     2
                   end
        baz = qux
      RUBY
    end

    it "does not register offense for &&= if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result &&= if condition
                     1
                   else
                     2
                   end
        baz = qux
      RUBY
    end

    it "does not register offense for += if assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result += if condition
                    1
                  else
                    2
                  end
        baz = qux
      RUBY
    end
  end

  context "with multiline block in method arguments" do
    it "does not register offense for block in method call" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        method_call(items.map do |item|
          item.upcase
        end)
        baz = qux
      RUBY
    end
  end

  context "with numblock lambda" do
    it "does not register offense for numblock lambda" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        my_proc = -> do
          _1 + _2
        end
        baz = qux
      RUBY
    end
  end

  context "when block is multiline but single line" do
    it "does not register offense for multiline case that fits one line" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result = case value; when :a then 1; end
        baz = qux
      RUBY
    end
  end

  context "with blocks having no parents" do
    it "handles top-level if block" do
      expect_no_offenses(<<~RUBY)
        if condition
          foo
        else
          bar
        end
      RUBY
    end

    it "handles top-level block" do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          process(item)
        end
      RUBY
    end
  end

  context "with rescue body containing multiple statements" do
    it "requires blank line around block in rescue with siblings" do
      expect_offense(<<~RUBY)
        begin
          something
        rescue
          log_error
          if condition
          ^^^^^^^^^^^^ Add empty line before multiline `if` block.
            handle_one
          else
            handle_other
          end
          ^^^ Add empty line after multiline `if` block.
          cleanup
        end
      RUBY
    end
  end

  context "with when body containing multiple statements" do
    it "requires blank line around block in when with siblings" do
      expect_offense(<<~RUBY)
        case value
        when :a
          setup
          if condition
          ^^^^^^^^^^^^ Add empty line before multiline `if` block.
            foo
          else
            bar
          end
          ^^^ Add empty line after multiline `if` block.
          teardown
        end
      RUBY
    end
  end

  context "with case else containing multiple statements" do
    it "requires blank line around block in case else with siblings" do
      expect_offense(<<~RUBY)
        case value
        when :a
          something
        else
          setup
          if condition
          ^^^^^^^^^^^^ Add empty line before multiline `if` block.
            foo
          else
            bar
          end
          ^^^ Add empty line after multiline `if` block.
          teardown
        end
      RUBY
    end
  end

  context "with if branch containing multiple statements" do
    it "requires blank line around nested block" do
      expect_offense(<<~RUBY)
        if outer
          setup
          if inner
          ^^^^^^^^ Add empty line before multiline `if` block.
            foo
          else
            bar
          end
          ^^^ Add empty line after multiline `if` block.
          teardown
        end
      RUBY
    end
  end

  context "with else branch containing multiple statements" do
    it "requires blank line around nested block" do
      expect_offense(<<~RUBY)
        if outer
          something
        else
          setup
          if inner
          ^^^^^^^^ Add empty line before multiline `if` block.
            foo
          else
            bar
          end
          ^^^ Add empty line after multiline `if` block.
          teardown
        end
      RUBY
    end
  end

  context "with block body containing multiple statements" do
    it "requires blank line around nested block" do
      expect_offense(<<~RUBY)
        outer.each do |item|
          setup(item)
          if condition
          ^^^^^^^^^^^^ Add empty line before multiline `if` block.
            process(item)
          else
            skip(item)
          end
          ^^^ Add empty line after multiline `if` block.
          cleanup(item)
        end
      RUBY
    end
  end

  context "with class method body containing multiple statements" do
    it "requires blank line around block" do
      expect_offense(<<~RUBY)
        def self.foo
          setup
          if condition
          ^^^^^^^^^^^^ Add empty line before multiline `if` block.
            bar
          else
            baz
          end
          ^^^ Add empty line after multiline `if` block.
          cleanup
        end
      RUBY
    end
  end

  context "with method body containing multiple statements" do
    it "requires blank line around block in method" do
      expect_offense(<<~RUBY)
        def foo
          setup
          if condition
          ^^^^^^^^^^^^ Add empty line before multiline `if` block.
            bar
          else
            baz
          end
          ^^^ Add empty line after multiline `if` block.
          cleanup
        end
      RUBY
    end
  end

  context "when comment is on first line of file" do
    it "does not require blank line at first line" do
      expect_no_offenses(<<~RUBY)
        # Comment on first line
        if condition
          foo
        else
          bar
        end
      RUBY
    end
  end

  context "with lambda that is not part of assignment" do
    it "does not register offense for standalone lambda" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        my_lambda = -> do
          puts "hello"
        end
        baz = qux
      RUBY
    end

    it "registers offense for lambda with explicit block followed by code" do
      expect_offense(<<~RUBY)
        foo = bar
        result = lambda do
          calculate_something
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end
  end

  context "when prev_sibling returns nil" do
    it "handles block as first expression in program" do
      expect_no_offenses(<<~RUBY)
        if condition
          foo
        else
          bar
        end
      RUBY
    end
  end

  context "when next_sibling returns nil" do
    it "handles block as last expression in program" do
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

  context "with multiline if without else" do
    it "registers offense for if without else" do
      expect_offense(<<~RUBY)
        foo = bar
        if condition
        ^^^^^^^^^^^^ Add empty line before multiline `if` block.
          baz
          qux
        end
        ^^^ Add empty line after multiline `if` block.
        quux = corge
      RUBY
    end
  end

  context "with empty line already between siblings" do
    it "does not register offense when properly spaced" do
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

  context "with single-line case" do
    it "does not register offense for single-line case" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        result = case x; when 1 then "a"; when 2 then "b"; end
        baz = qux
      RUBY
    end
  end

  context "with multiline numblock" do
    it "handles numblock without explicit params" do
      expect_offense(<<~RUBY)
        foo = bar
        [1, 2, 3].map do
        ^^^^^^^^^^^^^^^^ Add empty line before multiline `do...end` block.
          _1 * 2
        end
        ^^^ Add empty line after multiline `do...end` block.
        baz = qux
      RUBY
    end
  end

  context "with blocks without location info" do
    it "handles complex nested structures" do
      expect_no_offenses(<<~RUBY)
        class Foo
          def bar
            items.each do |item|
              if item.valid?
                process(item)
              else
                skip(item)
              end
            end
          end
        end
      RUBY
    end
  end

  context "when only child in class/module body" do
    it "does not require blank line when block is only child in class" do
      expect_no_offenses(<<~RUBY)
        class ExtractDataId < T::Enum
          enums do
            IndianaEmailParser = new("indiana-email-parser")
          end
        end
      RUBY
    end

    it "does not require blank line when block is only child in module" do
      expect_no_offenses(<<~RUBY)
        module MyModule
          setup do
            configure_something
          end
        end
      RUBY
    end

    it "does not require blank line when block is only child in singleton class" do
      expect_no_offenses(<<~RUBY)
        class << self
          define_method(:foo) do
            bar
          end
        end
      RUBY
    end

    it "requires blank line when block has siblings in class" do
      expect_offense(<<~RUBY)
        class MyClass
          attr_reader :foo
          setup do
          ^^^^^^^^ Add empty line before multiline `do...end` block.
            configure
          end
        end
      RUBY
    end
  end
end
