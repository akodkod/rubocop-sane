# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::EmptyLinesAroundMultilineCall, :config do
  context "with multiline method call with arguments" do
    it "registers offense for missing blank line before" do
      expect_offense(<<~RUBY)
        foo = bar
        something(
        ^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
          arg2,
        )
      RUBY

      expect_correction(<<~RUBY)
        foo = bar

        something(
          arg1,
          arg2,
        )
      RUBY
    end

    it "registers offense for missing blank line after" do
      expect_offense(<<~RUBY)
        something(
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY

      expect_correction(<<~RUBY)
        something(
          arg1,
          arg2,
        )

        baz = qux
      RUBY
    end

    it "registers offense for missing blank lines before and after" do
      expect_offense(<<~RUBY)
        foo = bar
        something(
        ^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY
    end
  end

  context "with multiline method chain" do
    it "registers offense for missing blank line before chain" do
      expect_offense(<<~RUBY)
        foo = bar
        result
        ^^^^^^ Add empty line before multiline method call.
          .method1
          .method2
      RUBY

      expect_correction(<<~RUBY)
        foo = bar

        result
          .method1
          .method2
      RUBY
    end

    it "registers offense for missing blank line after chain" do
      expect_offense(<<~RUBY)
        result
          .method1
          .method2
           ^^^^^^^ Add empty line after multiline method call.
        baz = qux
      RUBY

      expect_correction(<<~RUBY)
        result
          .method1
          .method2

        baz = qux
      RUBY
    end
  end

  context "with single-line call" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        something(arg1, arg2)
        baz = qux
      RUBY
    end
  end

  context "with properly spaced multiline call" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = bar

        something(
          arg1,
          arg2,
        )

        baz = qux
      RUBY
    end
  end

  context "when first/last/only child in method body" do
    it "does not require blank line at beginning of method" do
      expect_no_offenses(<<~RUBY)
        def foo
          something(
            arg1,
            arg2,
          )

          bar
        end
      RUBY
    end

    it "does not require blank line at end of method" do
      expect_no_offenses(<<~RUBY)
        def foo
          bar

          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end

    it "does not require blank line when only child in method" do
      expect_no_offenses(<<~RUBY)
        def foo
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end

    it "does not require blank line when only child in class method" do
      expect_no_offenses(<<~RUBY)
        def self.foo
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "with call that has a block" do
    it "does not register offense (block cop handles it)" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        items.each do |item|
          process(item)
        end
        baz = qux
      RUBY
    end

    it "does not register offense for curly block" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        items.each { |item|
          process(item)
        }
        baz = qux
      RUBY
    end
  end

  context "with inner chain call" do
    it "only checks outermost call" do
      expect_no_offenses(<<~RUBY)
        def foo
          result
            .method1
            .method2
        end
      RUBY
    end
  end

  context "with call as argument" do
    it "does not register offense for inner call" do
      expect_no_offenses(<<~RUBY)
        def foo
          outer_method(inner_method(
            arg1,
            arg2,
          ))
        end
      RUBY
    end
  end

  context "with call inside array" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        arr = [something(
          arg1,
          arg2,
        )]
        baz = qux
      RUBY
    end
  end

  context "with call inside hash" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        hash = { key: something(
          arg1,
          arg2,
        ) }
        baz = qux
      RUBY
    end
  end

  context "with setter call" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        obj.value = something(
          arg1,
          arg2,
        )
        baz = qux
      RUBY
    end
  end

  context "with return/break/next" do
    it "does not register offense for return" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        return something(
          arg1,
          arg2,
        )
      RUBY
    end

    it "does not register offense for break" do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          break something(
            arg1,
            arg2,
          )
        end
      RUBY
    end

    it "does not register offense for next" do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          next something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "with assignment" do
    it "checks around assignment node for local variable" do
      expect_offense(<<~RUBY)
        foo = bar
        result = something(
        ^^^^^^^^^^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY
    end

    it "checks around assignment node for instance variable" do
      expect_offense(<<~RUBY)
        foo = bar
        @result = something(
        ^^^^^^^^^^^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY
    end

    it "checks around assignment node for ||=" do
      expect_offense(<<~RUBY)
        foo = bar
        result ||= something(
        ^^^^^^^^^^^^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY
    end

    it "does not register offense when assignment is properly spaced" do
      expect_no_offenses(<<~RUBY)
        foo = bar

        result = something(
          arg1,
          arg2,
        )

        baz = qux
      RUBY
    end

    it "does not register offense when assignment is last in method" do
      expect_no_offenses(<<~RUBY)
        def foo
          bar

          result = something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "with comment before call" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        # This is a comment
        something(
          arg1,
          arg2,
        )
      RUBY
    end
  end

  context "with rubocop directive after call" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        something(
          arg1,
          arg2,
        )
        # rubocop:enable Style/Something
        foo = bar
      RUBY
    end
  end

  context "with multiple consecutive multiline calls" do
    it "registers offense when not separated" do
      expect_offense(<<~RUBY)
        foo = bar

        something(
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        another(
        ^^^^^^^^ Add empty line before multiline method call.
          arg3,
          arg4,
        )

        baz = qux
      RUBY
    end
  end

  context "when only child in body" do
    it "does not require blank line when only child in block" do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          something(
            item,
            arg2,
          )
        end
      RUBY
    end

    it "does not require blank line when only child in class" do
      expect_no_offenses(<<~RUBY)
        class MyClass
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end

    it "does not require blank line when only child in module" do
      expect_no_offenses(<<~RUBY)
        module MyModule
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end

    it "does not require blank line when only child in if branch" do
      expect_no_offenses(<<~RUBY)
        if condition
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end

    it "does not require blank line when only child in else branch" do
      expect_no_offenses(<<~RUBY)
        if condition
          foo
        else
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "with safe navigation method call" do
    it "registers offense for missing blank lines" do
      expect_offense(<<~RUBY)
        foo = bar
        result&.method1(
        ^^^^^^^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY
    end
  end

  context "with method call with receiver" do
    it "registers offense for missing blank lines" do
      expect_offense(<<~RUBY)
        foo = bar
        obj.method1(
        ^^^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY
    end
  end

  context "with auto-correction" do
    it "inserts blank line before multiline call" do
      expect_offense(<<~RUBY)
        foo = bar
        something(
        ^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
          arg2,
        )
      RUBY

      expect_correction(<<~RUBY)
        foo = bar

        something(
          arg1,
          arg2,
        )
      RUBY
    end

    it "inserts blank line after multiline call" do
      expect_offense(<<~RUBY)
        something(
          arg1,
          arg2,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY

      expect_correction(<<~RUBY)
        something(
          arg1,
          arg2,
        )

        baz = qux
      RUBY
    end
  end

  context "when before rescue clause" do
    it "does not require blank line before rescue" do
      expect_no_offenses(<<~RUBY)
        begin
          something(
            arg1,
            arg2,
          )
        rescue => e
          handle_error(e)
        end
      RUBY
    end
  end

  context "with numblock exclusion" do
    it "does not register offense when call has numblock" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        items.each do
          process(_1)
        end
        baz = qux
      RUBY
    end
  end

  context "with inner chain via safe navigation" do
    it "skips inner call in safe navigation chain" do
      expect_no_offenses(<<~RUBY)
        def foo
          result&.method1
            &.method2
        end
      RUBY
    end
  end

  context "when only child in when body" do
    it "does not require blank line" do
      expect_no_offenses(<<~RUBY)
        case value
        when :a
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "when only child in case else" do
    it "does not require blank line" do
      expect_no_offenses(<<~RUBY)
        case value
        when :a
          foo
        else
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "when only child in rescue body" do
    it "does not require blank line" do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "when only child in singleton class" do
    it "does not require blank line" do
      expect_no_offenses(<<~RUBY)
        class << self
          something(
            arg1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "when only child in numblock body" do
    it "does not require blank line" do
      expect_no_offenses(<<~RUBY)
        items.each do
          something(
            _1,
            arg2,
          )
        end
      RUBY
    end
  end

  context "with top-level multiline call" do
    it "does not require blank line when first statement" do
      expect_no_offenses(<<~RUBY)
        something(
          arg1,
          arg2,
        )

        baz
      RUBY
    end

    it "does not require blank line when last statement" do
      expect_no_offenses(<<~RUBY)
        foo

        something(
          arg1,
          arg2,
        )
      RUBY
    end
  end

  context "with call inside hash pair" do
    it "does not register offense for call as hash value" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        hash = { key: something(
          arg1,
          arg2,
        ) }
        baz = qux
      RUBY
    end
  end

  context "with multiline call in method body with siblings" do
    it "requires blank line around call in method" do
      expect_offense(<<~RUBY)
        def foo
          setup
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          cleanup
        end
      RUBY
    end
  end

  context "with assignment via setter of multiline call" do
    it "uses setter parent as effective target" do
      expect_no_offenses(<<~RUBY)
        foo = bar
        obj.value = something(
          arg1,
          arg2,
        )
        baz = qux
      RUBY
    end
  end

  context "with call as csend argument" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        def foo
          obj&.outer_method(inner_method(
            arg1,
            arg2,
          ))
        end
      RUBY
    end
  end

  context "with standalone multiline call (no parent)" do
    it "does not register offense for single top-level multiline call" do
      expect_no_offenses(<<~RUBY)
        something(
          arg1,
          arg2,
        )
      RUBY
    end
  end

  context "with multiline call in when body with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        case value
        when :a
          setup
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          teardown
        end
      RUBY
    end
  end

  context "with multiline call in case else with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        case value
        when :a
          foo
        else
          setup
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          teardown
        end
      RUBY
    end
  end

  context "with multiline call in rescue body with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        begin
          risky
        rescue
          log_error
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          cleanup
        end
      RUBY
    end
  end

  context "with multiline call in if branch with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        if condition
          setup
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          teardown
        end
      RUBY
    end
  end

  context "with multiline call in else branch with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        if condition
          foo
        else
          setup
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          teardown
        end
      RUBY
    end
  end

  context "with multiline call in class body with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        class MyClass
          attr_reader :foo
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          attr_reader :bar
        end
      RUBY
    end
  end

  context "with multiline call in singleton class body with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        class << self
          attr_reader :foo
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          attr_reader :bar
        end
      RUBY
    end
  end

  context "with multiline call in module body with siblings" do
    it "requires blank line around call" do
      expect_offense(<<~RUBY)
        module MyModule
          attr_reader :foo
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          attr_reader :bar
        end
      RUBY
    end
  end

  context "with comment on first line of file before call" do
    it "does not require blank line" do
      expect_no_offenses(<<~RUBY)
        # Comment on first line
        something(
          arg1,
          arg2,
        )
      RUBY
    end
  end

  context "with SkipMethods" do
    let(:cop_config) { { "Enabled" => true, "SkipMethods" => ["belongs_to", "has_one", "has_many"] } }

    it "does not register offense for belongs_to" do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          attr_reader :foo
          belongs_to :company,
            optional: true,
            class_name: "Company"
          attr_reader :bar
        end
      RUBY
    end

    it "does not register offense for has_many" do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          attr_reader :foo
          has_many :posts,
            dependent: :destroy,
            inverse_of: :user
          attr_reader :bar
        end
      RUBY
    end

    it "does not register offense for has_one" do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          attr_reader :foo
          has_one :profile,
            dependent: :destroy
          attr_reader :bar
        end
      RUBY
    end

    it "still registers offense for non-skipped methods" do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          attr_reader :foo
          something(
          ^^^^^^^^^^ Add empty line before multiline method call.
            arg1,
            arg2,
          )
          ^ Add empty line after multiline method call.
          attr_reader :bar
        end
      RUBY
    end
  end

  context "with sig blocks" do
    it "does not register offense for memoize def after inline sig block" do
      expect_no_offenses(<<~RUBY)
        class Foo
          sig { returns(String) }
          memoize def impersonate_params
            parse_params(ImpersonateParams)
          end
        end
      RUBY
    end

    it "does not register offense for memoize def after multiline sig block" do
      expect_no_offenses(<<~RUBY)
        class Foo
          sig do
            params(x: Integer).returns(String)
          end
          memoize def foo(x)
            x.to_s
          end
        end
      RUBY
    end

    it "does not register offense for regular def after sig block" do
      expect_no_offenses(<<~RUBY)
        class Foo
          sig { returns(String) }
          def bar
            "hello"
          end
        end
      RUBY
    end
  end

  context "with multiline chain using safe navigation" do
    it "registers offense for outermost safe navigation chain" do
      expect_offense(<<~RUBY)
        foo = bar
        result&.method1&.method2(
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line before multiline method call.
          arg1,
        )
        ^ Add empty line after multiline method call.
        baz = qux
      RUBY
    end
  end
end
