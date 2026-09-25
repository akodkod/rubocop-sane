# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::ConditionalAssignmentAllowTernary, :config do
  context "with setter assignments", :ruby32 do
    it "registers an offense for if/else with self as the receiver" do
      expect_offense(<<~RUBY)
        self.admin = if admin
        ^^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                       update!(admin, password:)
                     else
                       create!(Admin, name:, email:, password:)
                     end
      RUBY
    end

    it "registers an offense for if/else with another receiver" do
      expect_offense(<<~RUBY)
        record.name = if condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `if` branch.
                        "Alice"
                      else
                        "Bob"
                      end
      RUBY
    end

    it "registers an offense for case with self as the receiver" do
      expect_offense(<<~RUBY)
        self.admin = case role
        ^^^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `case` branch.
                     when :admin then true
                     else false
                     end
      RUBY
    end

    it "registers an offense for case with another receiver" do
      expect_offense(<<~RUBY)
        record.name = case role
        ^^^^^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `case` branch.
                      when :admin then "Alice"
                      else "Bob"
                      end
      RUBY
    end

    it "does not register an offense for ternaries" do
      expect_no_offenses(<<~RUBY)
        self.admin = condition ? true : false
        record.name = condition ? "Alice" : "Bob"
      RUBY
    end

    it "does not register an offense for multiline ternaries" do
      expect_no_offenses(<<~RUBY)
        self.admin = condition \\
          ? true
          : false
        record.name = condition \\
          ? "Alice"
          : "Bob"
      RUBY
    end

    it "does not register an offense for assignments inside the branches" do
      expect_no_offenses(<<~RUBY)
        if admin
          self.admin = update!(admin, password:)
        else
          self.admin = create!(Admin, name:, email:, password:)
        end
      RUBY
    end

    it "does not register an offense for if without else" do
      expect_no_offenses(<<~RUBY)
        record.name = if condition
                        "Alice"
                      end
      RUBY
    end
  end

  context "with ordinary method calls" do
    it "does not register an offense for if/else arguments" do
      expect_no_offenses(<<~RUBY)
        update(if condition
                 "Alice"
               else
                 "Bob"
               end)
        record.update(if condition
                        "Alice"
                      else
                        "Bob"
                      end)
      RUBY
    end

    it "does not register an offense for case arguments" do
      expect_no_offenses(<<~RUBY)
        update(case role
               when :admin then "Alice"
               else "Bob"
               end)
        record.update(case role
                      when :admin then "Alice"
                      else "Bob"
                      end)
      RUBY
    end

    it "does not register an offense for comparison methods" do
      expect_no_offenses(<<~RUBY)
        record.name == if condition
                         "Alice"
                       else
                         "Bob"
                       end
      RUBY
    end
  end

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

  context "with operator assignment to case" do
    it "registers an offense for += case" do
      expect_offense(<<~RUBY)
        foo += case bar
        ^^^^^^^^^^^^^^^ Move the assignment inside the `case` branch.
               when :a then 1
               when :b then 2
               end
      RUBY
    end

    it "registers an offense for ||= case" do
      expect_offense(<<~RUBY)
        foo ||= case bar
        ^^^^^^^^^^^^^^^^ Move the assignment inside the `case` branch.
                when :a then 1
                when :b then 2
                end
      RUBY
    end

    it "registers an offense for &&= case" do
      expect_offense(<<~RUBY)
        foo &&= case bar
        ^^^^^^^^^^^^^^^^ Move the assignment inside the `case` branch.
                when :a then 1
                when :b then 2
                end
      RUBY
    end
  end

  context "with namespaced constant assignment to case" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        Foo::BAR = case baz
        ^^^^^^^^^^^^^^^^^^^ Move the assignment inside the `case` branch.
                   when :a then 1
                   when :b then 2
                   end
      RUBY
    end
  end
end
