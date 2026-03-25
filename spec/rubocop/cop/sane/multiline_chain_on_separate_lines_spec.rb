# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::MultilineChainOnSeparateLines, :config do
  context "when dot is on the same line as multiline receiver's closing" do
    it "registers offenses for both .find and .click" do
      expect_offense(<<~RUBY)
        browser.find(
               ^ Place each method call in a multiline chain on a separate line with a leading dot.
          "selector",
          text: "foo",
        ).click
         ^ Place each method call in a multiline chain on a separate line with a leading dot.
      RUBY
    end

    it "registers offenses for method after multiline chain" do
      expect_offense(<<~RUBY)
        result.where(
              ^ Place each method call in a multiline chain on a separate line with a leading dot.
          active: true,
        ).order(:name)
         ^ Place each method call in a multiline chain on a separate line with a leading dot.
      RUBY
    end

    it "registers offenses for multiple chained methods after multiline calls" do
      expect_offense(<<~RUBY)
        foo.bar(
           ^ Place each method call in a multiline chain on a separate line with a leading dot.
          arg1,
        ).baz(
         ^ Place each method call in a multiline chain on a separate line with a leading dot.
          arg2,
        ).qux
         ^ Place each method call in a multiline chain on a separate line with a leading dot.
      RUBY
    end

    it "registers offenses with safe navigation" do
      expect_offense(<<~RUBY)
        browser&.find(
               ^^ Place each method call in a multiline chain on a separate line with a leading dot.
          "selector",
        )&.click
         ^^ Place each method call in a multiline chain on a separate line with a leading dot.
      RUBY
    end

    it "autocorrects dot after closing paren" do
      expect_offense(<<~RUBY)
        result
          .where(
            active: true,
          ).order(:name)
           ^ Place each method call in a multiline chain on a separate line with a leading dot.
      RUBY

      expect_correction(<<~RUBY)
        result
          .where(
            active: true,
          )
          .order(:name)
      RUBY
    end

    it "autocorrects safe navigation after closing paren" do
      expect_offense(<<~RUBY)
        result
          &.where(
            active: true,
          )&.order(:name)
           ^^ Place each method call in a multiline chain on a separate line with a leading dot.
      RUBY

      expect_correction(<<~RUBY)
        result
          &.where(
            active: true,
          )
          &.order(:name)
      RUBY
    end
  end

  context "when first method in chain has multiline args" do
    it "registers an offense when method is on same line as receiver and chained" do
      expect_offense(<<~RUBY)
        browser.find(
               ^ Place each method call in a multiline chain on a separate line with a leading dot.
          "selector",
        ).click
         ^ Place each method call in a multiline chain on a separate line with a leading dot.
      RUBY
    end

    it "does not register an offense for standalone multiline call without chain" do
      expect_no_offenses(<<~RUBY)
        foo.bar(
          arg1,
          arg2,
        )
      RUBY
    end
  end

  context "when chain is already correctly formatted" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        browser
          .find(
            "selector",
            text: "foo",
          )
          .click
      RUBY
    end

    it "does not register an offense for multiline chain with each method on own line" do
      expect_no_offenses(<<~RUBY)
        result
          .where(active: true)
          .order(:name)
          .first
      RUBY
    end
  end

  context "when chain is single-line" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        foo.bar.baz
      RUBY
    end

    it "does not register an offense for single-line with block" do
      expect_no_offenses(<<~RUBY)
        foo.map { |x| x }.compact
      RUBY
    end
  end

  context "when call is not a chain" do
    it "does not register an offense for simple method call" do
      expect_no_offenses(<<~RUBY)
        foo.bar
      RUBY
    end

    it "does not register an offense for method without receiver" do
      expect_no_offenses(<<~RUBY)
        puts(
          "hello",
          "world",
        )
      RUBY
    end

    it "does not register an offense for multiline call on non-send receiver" do
      expect_no_offenses(<<~RUBY)
        foo.bar(
          arg1,
          arg2,
        )
      RUBY
    end
  end

  context "with indentation" do
    it "indents relative to chain root" do
      expect_offense(<<~RUBY)
        def test
          browser.find(
                 ^ Place each method call in a multiline chain on a separate line with a leading dot.
            "selector",
          ).click
           ^ Place each method call in a multiline chain on a separate line with a leading dot.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          browser
            .find(
            "selector",
          )
            .click
        end
      RUBY
    end

    it "autocorrects dot on closing paren with correct indentation" do
      expect_offense(<<~RUBY)
        def test
          result
            .where(
              active: true,
            ).order(:name)
             ^ Place each method call in a multiline chain on a separate line with a leading dot.
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          result
            .where(
              active: true,
            )
            .order(:name)
        end
      RUBY
    end
  end
end
