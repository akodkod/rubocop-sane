# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::EmptyLinesAroundConditionBody, :config do
  context "when if body has empty line at the beginning" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        if condition

          body
          ^^^^ Remove empty line at the beginning of condition body
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          body
        end
      RUBY
    end
  end

  context "when if body has empty line at the end" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        if condition
          body

        end
        ^^^ Remove empty line at the end of condition body
      RUBY

      expect_correction(<<~RUBY)
        if condition
          body
        end
      RUBY
    end
  end

  context "when if body has empty lines at both beginning and end" do
    it "registers offenses for both" do
      expect_offense(<<~RUBY)
        if condition

          body
          ^^^^ Remove empty line at the beginning of condition body

        end
        ^^^ Remove empty line at the end of condition body
      RUBY

      expect_correction(<<~RUBY)
        if condition
          body
        end
      RUBY
    end
  end

  context "when else body has empty lines" do
    it "registers offenses" do
      expect_offense(<<~RUBY)
        if condition
          body
        else

          another_body
          ^^^^^^^^^^^^ Remove empty line at the beginning of condition body

        end
        ^^^ Remove empty line at the end of condition body
      RUBY

      expect_correction(<<~RUBY)
        if condition
          body
        else
          another_body
        end
      RUBY
    end
  end

  context "when elsif body has empty lines" do
    it "registers offenses" do
      expect_offense(<<~RUBY)
        if condition
          body
        elsif other_condition

          another_body
          ^^^^^^^^^^^^ Remove empty line at the beginning of condition body

        end
        ^^^ Remove empty line at the end of condition body
      RUBY

      expect_correction(<<~RUBY)
        if condition
          body
        elsif other_condition
          another_body
        end
      RUBY
    end
  end

  context "when if/elsif/else all have empty lines" do
    it "registers offenses for all branches" do
      expect_offense(<<~RUBY)
        if condition

          body
          ^^^^ Remove empty line at the beginning of condition body

        elsif other_condition
        ^^^^^ Remove empty line at the end of condition body

          another_body
          ^^^^^^^^^^^^ Remove empty line at the beginning of condition body

        else
        ^^^^ Remove empty line at the end of condition body

          final_body
          ^^^^^^^^^^ Remove empty line at the beginning of condition body

        end
        ^^^ Remove empty line at the end of condition body
      RUBY

      expect_correction(<<~RUBY)
        if condition
          body
        elsif other_condition
          another_body
        else
          final_body
        end
      RUBY
    end
  end

  context "when unless body has empty lines" do
    it "registers offenses" do
      expect_offense(<<~RUBY)
        unless condition

          body
          ^^^^ Remove empty line at the beginning of condition body

        end
        ^^^ Remove empty line at the end of condition body
      RUBY

      expect_correction(<<~RUBY)
        unless condition
          body
        end
      RUBY
    end
  end

  context "when condition body has no empty lines" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        if condition
          body
        else
          another_body
        end
      RUBY
    end
  end

  context "when using ternary operator" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        condition ? body : another_body
      RUBY
    end
  end

  context "when using modifier form" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        body if condition
      RUBY
    end
  end

  context "when body has multiple statements" do
    it "registers offenses for empty lines at boundaries" do
      expect_offense(<<~RUBY)
        if condition

          first
          ^^^^^ Remove empty line at the beginning of condition body
          second

        end
        ^^^ Remove empty line at the end of condition body
      RUBY

      expect_correction(<<~RUBY)
        if condition
          first
          second
        end
      RUBY
    end
  end

  context "when body has empty lines in the middle" do
    it "does not register an offense for middle empty lines" do
      expect_no_offenses(<<~RUBY)
        if condition
          first

          second
        end
      RUBY
    end
  end
end
