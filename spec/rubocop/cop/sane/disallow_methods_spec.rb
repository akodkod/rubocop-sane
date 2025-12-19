# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::DisallowMethods, :config do
  let(:cop_config) do
    {
      "ReplaceMethods" => {
        "deliver_now" => {
          "with" => "deliver_later",
          "reason" => "`deliver_later` sends the email via background job",
        },
        "perform_sync" => {
          "with" => "perform_async!",
          "reason" => "`perform_async!` processes the job asynchronously",
        },
      },
      "ProhibitedMethods" => {
        "dangerous_method" => {
          "reason" => "this method is deprecated",
        },
      },
    }
  end

  context "when a replaceable method is used" do
    it "registers an offense for deliver_now" do
      expect_offense(<<~RUBY)
        UserMailer.welcome(user).deliver_now
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You should use `deliver_later` instead of `deliver_now` because `deliver_later` sends the email via background job
      RUBY

      expect_correction(<<~RUBY)
        UserMailer.welcome(user).deliver_later
      RUBY
    end

    it "registers an offense for perform_sync" do
      expect_offense(<<~RUBY)
        SomeWorker.perform_sync(args)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ You should use `perform_async!` instead of `perform_sync` because `perform_async!` processes the job asynchronously
      RUBY

      expect_correction(<<~RUBY)
        SomeWorker.perform_async!(args)
      RUBY
    end

    it "registers an offense when chained" do
      expect_offense(<<~RUBY)
        foo.bar.baz.deliver_now
        ^^^^^^^^^^^^^^^^^^^^^^^ You should use `deliver_later` instead of `deliver_now` because `deliver_later` sends the email via background job
      RUBY

      expect_correction(<<~RUBY)
        foo.bar.baz.deliver_later
      RUBY
    end
  end

  context "when a prohibited method is used" do
    it "registers an offense without autocorrection" do
      expect_offense(<<~RUBY)
        obj.dangerous_method
        ^^^^^^^^^^^^^^^^^^^^ You should not use `dangerous_method` because this method is deprecated
      RUBY

      expect_no_corrections
    end

    it "registers an offense when called without receiver" do
      expect_offense(<<~RUBY)
        dangerous_method
        ^^^^^^^^^^^^^^^^ You should not use `dangerous_method` because this method is deprecated
      RUBY

      expect_no_corrections
    end
  end

  context "when allowed methods are used" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        UserMailer.welcome(user).deliver_later
        SomeWorker.perform_async!(args)
        obj.safe_method
      RUBY
    end
  end

  context "with empty configuration" do
    let(:cop_config) do
      {
        "ReplaceMethods" => {},
        "ProhibitedMethods" => {},
      }
    end

    it "does not register any offenses" do
      expect_no_offenses(<<~RUBY)
        obj.deliver_now
        obj.dangerous_method
      RUBY
    end
  end

  context "with nil configuration" do
    let(:cop_config) do
      {
        "ReplaceMethods" => nil,
        "ProhibitedMethods" => nil,
      }
    end

    it "does not register any offenses" do
      expect_no_offenses(<<~RUBY)
        obj.deliver_now
        obj.dangerous_method
      RUBY
    end
  end

  describe "#safe_autocorrect?" do
    it "returns false" do
      expect(cop.send(:safe_autocorrect?)).to be(false)
    end
  end
end
