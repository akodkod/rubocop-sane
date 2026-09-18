# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::ProhibitedComments, :config do
  context "with custom prohibited words" do
    let(:cop_config) { { "ProhibitedWords" => ["TODO", "FIX.ME"] } }

    it "registers an offense for a configured word" do
      expect_offense(<<~RUBY, severity: :warning)
        # TODO: finish this
        ^^^^^^^^^^^^^^^^^^^ TODO comment found — review and address the comment
      RUBY
    end

    it "treats configured words as literal strings" do
      expect_offense(<<~RUBY)
        # FIX.ME
        ^^^^^^^^ FIX.ME comment found — review and address the comment
      RUBY

      expect_no_offenses(<<~RUBY)
        # FIXxME
      RUBY
    end

    it "replaces the default words" do
      expect_no_offenses(<<~RUBY)
        # DELETE this
        # delete this
        # REMEMBER this
        # remember this
      RUBY
    end

    it "only matches case-sensitive words at the start of comments" do
      expect_no_offenses(<<~RUBY)
        # todo
        # TODOs
        # This is a TODO
      RUBY
    end
  end

  context "with no prohibited words" do
    let(:cop_config) { { "ProhibitedWords" => [] } }

    it "does not register offenses" do
      expect_no_offenses(<<~RUBY)
        # DELETE
        # REMEMBER
        # TODO
        # ordinary comment
      RUBY
    end
  end

  context "when comment starts with DELETE" do
    it "registers an offense for standalone DELETE" do
      expect_offense(<<~RUBY, severity: :warning)
        # DELETE
        ^^^^^^^^ DELETE comment found — review and address the comment
      RUBY
    end

    it "registers an offense for DELETE with description" do
      expect_offense(<<~RUBY)
        # DELETE this code after migration
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ DELETE comment found — review and address the comment
      RUBY
    end

    it "registers an offense for DELETE with colon" do
      expect_offense(<<~RUBY)
        # DELETE: remove after v2
        ^^^^^^^^^^^^^^^^^^^^^^^^^ DELETE comment found — review and address the comment
      RUBY
    end

    it "registers an offense for lowercase delete" do
      expect_offense(<<~RUBY)
        # delete this
        ^^^^^^^^^^^^^ delete comment found — review and address the comment
      RUBY
    end

    it "registers an offense for DELETE without space after hash" do
      expect_offense(<<~RUBY)
        #DELETE
        ^^^^^^^ DELETE comment found — review and address the comment
      RUBY
    end
  end

  context "when comment starts with REMEMBER" do
    it "registers an offense for standalone REMEMBER" do
      expect_offense(<<~RUBY, severity: :warning)
        # REMEMBER
        ^^^^^^^^^^ REMEMBER comment found — review and address the comment
      RUBY
    end

    it "registers an offense for REMEMBER with description" do
      expect_offense(<<~RUBY)
        # REMEMBER to update the docs
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ REMEMBER comment found — review and address the comment
      RUBY
    end

    it "registers an offense for REMEMBER with colon" do
      expect_offense(<<~RUBY)
        # REMEMBER: notify the team
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ REMEMBER comment found — review and address the comment
      RUBY
    end

    it "registers an offense for lowercase remember" do
      expect_offense(<<~RUBY)
        # remember to do this
        ^^^^^^^^^^^^^^^^^^^^^ remember comment found — review and address the comment
      RUBY
    end

    it "registers an offense for REMEMBER without space after hash" do
      expect_offense(<<~RUBY)
        #REMEMBER
        ^^^^^^^^^ REMEMBER comment found — review and address the comment
      RUBY
    end
  end

  context "when comment does not start with a prohibited keyword" do
    it "does not flag DELETED" do
      expect_no_offenses(<<~RUBY)
        # DELETED items are archived
      RUBY
    end

    it "does not flag mixed case Delete" do
      expect_no_offenses(<<~RUBY)
        # Delete this later
      RUBY
    end

    it "does not flag delete in the middle of a comment" do
      expect_no_offenses(<<~RUBY)
        # This deletes the record
      RUBY
    end

    it "does not flag REMEMBERED" do
      expect_no_offenses(<<~RUBY)
        # REMEMBERED to fix the tests
      RUBY
    end

    it "does not flag mixed case Remember" do
      expect_no_offenses(<<~RUBY)
        # Remember this later
      RUBY
    end

    it "does not flag remember in the middle of a comment" do
      expect_no_offenses(<<~RUBY)
        # I need to remember this
      RUBY
    end

    it "does not flag regular comments" do
      expect_no_offenses(<<~RUBY)
        # TODO: clean up later
      RUBY
    end
  end
end
