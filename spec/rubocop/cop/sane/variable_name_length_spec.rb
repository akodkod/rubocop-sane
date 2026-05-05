# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::VariableNameLength, :config do
  let(:cop_config) do
    {
      "MinLength" => 3,
      "AllowedNames" => ["i", "j", "k", "n", "e", "x", "y", "_"],
    }
  end

  context "with local variable assignments" do
    it "registers an offense for a single-character variable name" do
      expect_offense(<<~RUBY)
        a = 1
        ^^^^^ Variable name 'a' is too short (minimum is 3 characters).
      RUBY
    end

    it "registers an offense for a two-character variable name" do
      expect_offense(<<~RUBY)
        ab = 2
        ^^^^^^ Variable name 'ab' is too short (minimum is 3 characters).
      RUBY
    end

    it "does not register an offense for a variable meeting minimum length" do
      expect_no_offenses(<<~RUBY)
        age = 1
        name = "foo"
      RUBY
    end
  end

  context "with method parameters" do
    it "registers an offense for short parameter names" do
      expect_offense(<<~RUBY)
        def foo(a, bb)
                   ^^ Variable name 'bb' is too short (minimum is 3 characters).
                ^ Variable name 'a' is too short (minimum is 3 characters).
        end
      RUBY
    end

    it "does not register an offense for long parameter names" do
      expect_no_offenses(<<~RUBY)
        def foo(name, age)
        end
      RUBY
    end

    it "registers an offense for short optional parameter names" do
      expect_offense(<<~RUBY)
        def foo(ab = 1)
                ^^^^^^ Variable name 'ab' is too short (minimum is 3 characters).
        end
      RUBY
    end

    it "registers an offense for short keyword parameter names" do
      expect_offense(<<~RUBY)
        def foo(ab:)
                ^^^ Variable name 'ab' is too short (minimum is 3 characters).
        end
      RUBY
    end

    it "registers an offense for short optional keyword parameter names" do
      expect_offense(<<~RUBY)
        def foo(ab: 1)
                ^^^^^ Variable name 'ab' is too short (minimum is 3 characters).
        end
      RUBY
    end
  end

  context "with block parameters" do
    it "registers an offense for short block parameter names" do
      expect_offense(<<~RUBY)
        items.each { |a| puts a }
                      ^ Variable name 'a' is too short (minimum is 3 characters).
      RUBY
    end

    it "does not register for allowed block parameter names" do
      expect_no_offenses(<<~RUBY)
        items.each_with_index { |item, i| puts item }
      RUBY
    end
  end

  context "with allowed names" do
    it "does not register an offense for allowed single-character names" do
      expect_no_offenses(<<~RUBY)
        i = 0
        j = 1
        k = 2
        n = 10
        x = 3.0
        y = 4.0
      RUBY
    end

    it "does not register an offense for rescue variable e" do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue StandardError => e
          handle(e)
        end
      RUBY
    end
  end

  context "with underscore-prefixed variables" do
    it "does not register an offense for underscore-prefixed names" do
      expect_no_offenses(<<~RUBY)
        _a = 1
        _ = unused
      RUBY
    end
  end

  context "with custom MinLength" do
    let(:cop_config) do
      {
        "MinLength" => 4,
        "AllowedNames" => [],
      }
    end

    it "registers an offense for names shorter than custom minimum" do
      expect_offense(<<~RUBY)
        age = 30
        ^^^^^^^^ Variable name 'age' is too short (minimum is 4 characters).
      RUBY
    end

    it "does not register an offense for names meeting custom minimum" do
      expect_no_offenses(<<~RUBY)
        name = "foo"
      RUBY
    end
  end

  context "with custom AllowedNames" do
    let(:cop_config) do
      {
        "MinLength" => 3,
        "AllowedNames" => ["id"],
      }
    end

    it "does not register an offense for custom allowed names" do
      expect_no_offenses(<<~RUBY)
        id = 42
      RUBY
    end

    it "registers an offense for names not in custom allowed list" do
      expect_offense(<<~RUBY)
        i = 0
        ^^^^^ Variable name 'i' is too short (minimum is 3 characters).
      RUBY
    end
  end
end
