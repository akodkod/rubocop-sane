# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::EmptyLineBeforeComment, :config do
  context "when comment lacks blank line before it" do
    it "registers offense for comment after code" do
      expect_offense(<<~RUBY)
        foo = 1
        # This is a comment
        ^^^^^^^^^^^^^^^^^^^ Add empty line before comment.
        bar = 2
      RUBY

      expect_correction(<<~RUBY)
        foo = 1

        # This is a comment
        bar = 2
      RUBY
    end

    it "registers offense for comment after method call" do
      expect_offense(<<~RUBY)
        do_something
        # Explain next step
        ^^^^^^^^^^^^^^^^^^^ Add empty line before comment.
        do_another_thing
      RUBY

      expect_correction(<<~RUBY)
        do_something

        # Explain next step
        do_another_thing
      RUBY
    end
  end

  context "when comment has blank line before it" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        foo = 1

        # This is a comment
        bar = 2
      RUBY
    end
  end

  context "when comment is on first line" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        # This is a comment on the first line
        foo = 1
      RUBY
    end
  end

  context "with consecutive comments" do
    it "does not register offense for comments following comments" do
      expect_no_offenses(<<~RUBY)
        foo = 1

        # First comment
        # Second comment
        # Third comment
        bar = 2
      RUBY
    end

    it "registers offense only for first comment in group" do
      expect_offense(<<~RUBY)
        foo = 1
        # First comment
        ^^^^^^^^^^^^^^^ Add empty line before comment.
        # Second comment
        bar = 2
      RUBY
    end
  end

  context "when after class definition start" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        class Foo
          # Class-level comment
          def bar
          end
        end
      RUBY
    end
  end

  context "when after module definition start" do
    it "does not register offense" do
      expect_no_offenses(<<~RUBY)
        module Foo
          # Module-level comment
          def bar
          end
        end
      RUBY
    end
  end

  context "when after method definition start" do
    it "does not register offense for def" do
      expect_no_offenses(<<~RUBY)
        def foo
          # Method comment
          bar
        end
      RUBY
    end

    it "does not register offense for class method def" do
      expect_no_offenses(<<~RUBY)
        def self.foo
          # Method comment
          bar
        end
      RUBY
    end
  end

  context "when after control structure start" do
    it "does not register offense after if" do
      expect_no_offenses(<<~RUBY)
        if condition
          # Comment inside if
          do_something
        end
      RUBY
    end

    it "does not register offense after unless" do
      expect_no_offenses(<<~RUBY)
        unless condition
          # Comment inside unless
          do_something
        end
      RUBY
    end

    it "does not register offense after case" do
      expect_no_offenses(<<~RUBY)
        case value
          # Comment after case
        when :a
          handle_a
        end
      RUBY
    end

    it "does not register offense after while" do
      expect_no_offenses(<<~RUBY)
        while condition
          # Comment inside while
          do_something
        end
      RUBY
    end

    it "does not register offense after until" do
      expect_no_offenses(<<~RUBY)
        until condition
          # Comment inside until
          do_something
        end
      RUBY
    end

    it "does not register offense after begin" do
      expect_no_offenses(<<~RUBY)
        begin
          # Comment inside begin
          do_something
        end
      RUBY
    end

    it "does not register offense after for" do
      expect_no_offenses(<<~RUBY)
        for i in items
          # Comment inside for
          process(i)
        end
      RUBY
    end
  end

  context "when after block openers" do
    it "does not register offense after do" do
      expect_no_offenses(<<~RUBY)
        items.each do |item|
          # Comment inside block
          process(item)
        end
      RUBY
    end

    it "does not register offense after do with no params" do
      expect_no_offenses(<<~RUBY)
        loop do
          # Comment inside block
          break if done?
        end
      RUBY
    end

    it "does not register offense after brace block" do
      expect_no_offenses(<<~RUBY)
        items.each {
          # Comment inside block
          |item| process(item)
        }
      RUBY
    end

    it "does not register offense after brace block with params" do
      expect_no_offenses(<<~RUBY)
        items.each { |item|
          # Comment inside block
          process(item)
        }
      RUBY
    end
  end

  context "when after rescue/ensure/else/elsif/when" do
    it "does not register offense after rescue" do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue
          # Handle error
          handle_error
        end
      RUBY
    end

    it "does not register offense after ensure" do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        ensure
          # Always run
          cleanup
        end
      RUBY
    end

    it "does not register offense after else" do
      expect_no_offenses(<<~RUBY)
        if condition
          foo
        else
          # Else branch
          bar
        end
      RUBY
    end

    it "does not register offense after elsif" do
      expect_no_offenses(<<~RUBY)
        if condition1
          foo
        elsif condition2
          # Elsif branch
          bar
        end
      RUBY
    end

    it "does not register offense after when" do
      expect_no_offenses(<<~RUBY)
        case value
        when :a
          # Handle a
          handle_a
        when :b
          handle_b
        end
      RUBY
    end
  end

  context "when after access modifiers" do
    it "does not register offense after private" do
      expect_no_offenses(<<~RUBY)
        class Foo
          def public_method
          end

          private
          # Private methods below
          def private_method
          end
        end
      RUBY
    end

    it "does not register offense after protected" do
      expect_no_offenses(<<~RUBY)
        class Foo
          protected
          # Protected methods
          def protected_method
          end
        end
      RUBY
    end

    it "does not register offense after public" do
      expect_no_offenses(<<~RUBY)
        class Foo
          private

          def private_method
          end

          public
          # Public again
          def public_method
          end
        end
      RUBY
    end
  end

  context "with inline comments" do
    it "does not register offense for inline comments" do
      expect_no_offenses(<<~RUBY)
        foo = 1 # inline comment
        bar = 2
      RUBY
    end

    it "does not register offense for inline rubocop directive" do
      expect_no_offenses(<<~RUBY)
        bar = 0
        ticket.update_column(:search_text, nil) # rubocop:disable Rails/SkipsModelValidations
        baz = 1
      RUBY
    end

    it "does not register offense for inline comment after code" do
      expect_no_offenses(<<~RUBY)
        first_line
        second_line # This is an inline comment
        third_line
      RUBY
    end
  end

  context "with multiple code blocks" do
    it "registers offense for each comment missing blank line" do
      expect_offense(<<~RUBY)
        foo = 1
        # First section
        ^^^^^^^^^^^^^^^ Add empty line before comment.
        bar = 2

        # Second section
        baz = 3
        # Third section
        ^^^^^^^^^^^^^^^ Add empty line before comment.
        qux = 4
      RUBY
    end
  end

  context "when in nested structures" do
    it "handles deeply nested code" do
      expect_no_offenses(<<~RUBY)
        class Foo
          def bar
            if condition
              # Nested comment is fine
              do_something
            end
          end
        end
      RUBY
    end

    it "registers offense in nested code when needed" do
      expect_offense(<<~RUBY)
        class Foo
          def bar
            do_something
            # This needs a blank line
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line before comment.
            do_another
          end
        end
      RUBY
    end
  end
end
