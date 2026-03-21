# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::RedundantSelfAssignment, :config do
  context "when using method-based assignment" do
    it "registers an offense for `self.foo ||= self.foo = value`" do
      expect_offense(<<~RUBY)
        self.browser ||= self.browser = Capybara::Session.new(:cuprite)
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant assignment in `||=`. Use `self.browser ||= Capybara::Session.new(:cuprite)` instead.
      RUBY

      expect_correction(<<~RUBY)
        self.browser ||= Capybara::Session.new(:cuprite)
      RUBY
    end

    it "registers an offense for `obj.foo ||= obj.foo = value`" do
      expect_offense(<<~RUBY)
        obj.foo ||= obj.foo = bar
                    ^^^^^^^^^^^^^ Redundant assignment in `||=`. Use `obj.foo ||= bar` instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.foo ||= bar
      RUBY
    end

    it "does not register an offense for different receivers" do
      expect_no_offenses(<<~RUBY)
        self.foo ||= other.foo = val
      RUBY
    end

    it "does not register an offense for different method names" do
      expect_no_offenses(<<~RUBY)
        self.foo ||= self.bar = val
      RUBY
    end
  end

  context "when using instance variable assignment" do
    it "registers an offense for `@foo ||= @foo = value`" do
      expect_offense(<<~RUBY)
        @foo ||= @foo = compute_value
                 ^^^^^^^^^^^^^^^^^^^^ Redundant assignment in `||=`. Use `@foo ||= compute_value` instead.
      RUBY

      expect_correction(<<~RUBY)
        @foo ||= compute_value
      RUBY
    end

    it "does not register an offense for different instance variables" do
      expect_no_offenses(<<~RUBY)
        @foo ||= @bar = val
      RUBY
    end
  end

  context "when using class variable assignment" do
    it "registers an offense for `@@foo ||= @@foo = value`" do
      expect_offense(<<~RUBY)
        @@foo ||= @@foo = 42
                  ^^^^^^^^^^ Redundant assignment in `||=`. Use `@@foo ||= 42` instead.
      RUBY

      expect_correction(<<~RUBY)
        @@foo ||= 42
      RUBY
    end
  end

  context "when using local variable assignment" do
    it "registers an offense for `foo ||= foo = value`" do
      expect_offense(<<~RUBY)
        foo ||= foo = 42
                ^^^^^^^^ Redundant assignment in `||=`. Use `foo ||= 42` instead.
      RUBY

      expect_correction(<<~RUBY)
        foo ||= 42
      RUBY
    end

    it "does not register an offense for different local variables" do
      expect_no_offenses(<<~RUBY)
        foo ||= bar = 42
      RUBY
    end
  end

  context "when using global variable assignment" do
    it "registers an offense for `$foo ||= $foo = value`" do
      expect_offense(<<~RUBY)
        $foo ||= $foo = 42
                 ^^^^^^^^^ Redundant assignment in `||=`. Use `$foo ||= 42` instead.
      RUBY

      expect_correction(<<~RUBY)
        $foo ||= 42
      RUBY
    end
  end

  context "when using constant assignment" do
    it "registers an offense for `FOO ||= FOO = value`" do
      expect_offense(<<~RUBY)
        FOO ||= FOO = 42
                ^^^^^^^^ Redundant assignment in `||=`. Use `FOO ||= 42` instead.
      RUBY

      expect_correction(<<~RUBY)
        FOO ||= 42
      RUBY
    end
  end

  context "when using normal `||=` without redundancy" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        self.browser ||= Capybara::Session.new(:cuprite)
      RUBY
    end

    it "does not register an offense for variable" do
      expect_no_offenses(<<~RUBY)
        @foo ||= compute_value
      RUBY
    end
  end
end
