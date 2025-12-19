# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::ConditionalAssignmentAllowTernary, :config do
  context "when assigning from if/else" do
    it "registers an offense for local variable assignment" do
      expect_offense(<<~RUBY)
        foo = if condition
        ^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                1
              else
                2
              end
      RUBY
    end

    it "registers an offense for instance variable assignment" do
      expect_offense(<<~RUBY)
        @foo = if condition
        ^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                 1
               else
                 2
               end
      RUBY
    end

    it "registers an offense for class variable assignment" do
      expect_offense(<<~RUBY)
        @@foo = if condition
        ^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                  1
                else
                  2
                end
      RUBY
    end

    it "registers an offense for global variable assignment" do
      expect_offense(<<~RUBY)
        $foo = if condition
        ^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                 1
               else
                 2
               end
      RUBY
    end

    it "registers an offense for constant assignment" do
      expect_offense(<<~RUBY)
        FOO = if condition
        ^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                1
              else
                2
              end
      RUBY
    end
  end

  context "when assigning from case/when" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        foo = case bar
        ^^^^^^^^^^^^^^ Move the assignment inside the `case` branch.
              when :a then 1
              when :b then 2
              end
      RUBY
    end
  end

  context "when assigning from unless/else" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        foo = unless condition
        ^^^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `unless` branch.
                1
              else
                2
              end
      RUBY
    end
  end

  context "with ternary operators" do
    it "does not register an offense for simple ternary" do
      expect_no_offenses(<<~RUBY)
        foo = condition ? 1 : 2
      RUBY
    end

    it "does not register an offense for multiline ternary" do
      expect_no_offenses(<<~RUBY)
        foo = condition \\
          ? 1
          : 2
      RUBY
    end
  end

  context "with assignment inside condition" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        if condition
          foo = 1
        else
          foo = 2
        end
      RUBY
    end
  end

  context "when if has no else branch" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        foo = if condition
                1
              end
      RUBY
    end
  end

  context "with multiple assignment" do
    it "registers an offense for multiple assignment" do
      expect_offense(<<~RUBY)
        a, b = if condition
        ^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                 [1, 2]
               else
                 [3, 4]
               end
      RUBY
    end
  end

  context "with operator assignment" do
    it "registers an offense for += assignment" do
      expect_offense(<<~RUBY)
        foo += if condition
        ^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                 1
               else
                 2
               end
      RUBY
    end

    it "registers an offense for ||= assignment" do
      expect_offense(<<~RUBY)
        foo ||= if condition
        ^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                  1
                else
                  2
                end
      RUBY
    end

    it "registers an offense for &&= assignment" do
      expect_offense(<<~RUBY)
        foo &&= if condition
        ^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                  1
                else
                  2
                end
      RUBY
    end
  end

  context "with namespaced constant assignment" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        Foo::BAR = if condition
        ^^^^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                     1
                   else
                     2
                   end
      RUBY
    end
  end

  context "when rhs is not a conditional" do
    it "does not register an offense for regular assignment" do
      expect_no_offenses(<<~RUBY)
        foo = bar
      RUBY
    end

    it "does not register an offense for method call" do
      expect_no_offenses(<<~RUBY)
        foo = some_method(arg)
      RUBY
    end
  end
end
