# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::OmitParentheses, :config do
  let(:cop_config) do
    {
      "Methods" => ["render_record", "render_service", "Log.info", "Log.warn"],
    }
  end

  context "when parentheses are used on a configured method" do
    it "registers an offense for a simple method with one argument" do
      expect_offense(<<~RUBY)
        render_record(record)
        ^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for `render_record`.
      RUBY

      expect_correction(<<~RUBY)
        render_record record
      RUBY
    end

    it "registers an offense for a method with no arguments" do
      expect_offense(<<~RUBY)
        render_record()
        ^^^^^^^^^^^^^^^ Omit parentheses for `render_record`.
      RUBY

      expect_correction(<<~RUBY)
        render_record
      RUBY
    end

    it "registers an offense for a method with multiple arguments" do
      expect_offense(<<~RUBY)
        render_record(a, b)
        ^^^^^^^^^^^^^^^^^^^ Omit parentheses for `render_record`.
      RUBY

      expect_correction(<<~RUBY)
        render_record a, b
      RUBY
    end

    it "registers an offense for a receiver-qualified method" do
      expect_offense(<<~RUBY)
        Log.info("message")
        ^^^^^^^^^^^^^^^^^^^ Omit parentheses for `Log.info`.
      RUBY

      expect_correction(<<~RUBY)
        Log.info "message"
      RUBY
    end

    it "registers an offense for a multiline string argument" do
      expect_offense(<<~RUBY)
        Log.info("some very long " \\
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for `Log.info`.
                 "multiline string")
      RUBY

      expect_correction(<<~RUBY)
        Log.info "some very long " \\
                 "multiline string"
      RUBY
    end

    it "registers an offense for a call with a multiline hash argument" do
      expect_offense(<<~RUBY)
        Log.info("msg", {
        ^^^^^^^^^^^^^^^^^ Omit parentheses for `Log.info`.
          key: value,
          other: data
        })
      RUBY

      expect_correction(<<~RUBY)
        Log.info "msg", {
          key: value,
          other: data
        }
      RUBY
    end
  end

  context "when parentheses are not used" do
    it "does not register an offense for a call without parentheses" do
      expect_no_offenses(<<~RUBY)
        render_record record
      RUBY
    end

    it "does not register an offense for a call with no arguments and no parentheses" do
      expect_no_offenses(<<~RUBY)
        render_record
      RUBY
    end
  end

  context "when the method is not in the configured list" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        some_other_method(arg)
      RUBY
    end
  end

  context "when receiver does not match for a qualified method" do
    it "does not register an offense for a different receiver" do
      expect_no_offenses(<<~RUBY)
        Other.info("msg")
      RUBY
    end
  end

  context "with empty configuration" do
    let(:cop_config) do
      { "Methods" => [] }
    end

    it "does not register any offenses" do
      expect_no_offenses(<<~RUBY)
        render_record(record)
        Log.info("msg")
      RUBY
    end
  end
end
