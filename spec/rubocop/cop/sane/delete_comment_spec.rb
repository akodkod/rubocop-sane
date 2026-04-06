# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::DeleteComment, :config do
  context "when comment starts with DELETE" do
    it "registers an offense for standalone DELETE" do
      expect_offense(<<~RUBY)
        # DELETE
        ^^^^^^^^ DELETE comment found — review and remove the marked code
      RUBY
    end

    it "registers an offense for DELETE with description" do
      expect_offense(<<~RUBY)
        # DELETE this code after migration
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ DELETE comment found — review and remove the marked code
      RUBY
    end

    it "registers an offense for DELETE with colon" do
      expect_offense(<<~RUBY)
        # DELETE: remove after v2
        ^^^^^^^^^^^^^^^^^^^^^^^^^ DELETE comment found — review and remove the marked code
      RUBY
    end

    it "registers an offense for lowercase delete" do
      expect_offense(<<~RUBY)
        # delete this
        ^^^^^^^^^^^^^ DELETE comment found — review and remove the marked code
      RUBY
    end

    it "registers an offense for DELETE without space after hash" do
      expect_offense(<<~RUBY)
        #DELETE
        ^^^^^^^ DELETE comment found — review and remove the marked code
      RUBY
    end
  end

  context "when comment does not start with DELETE" do
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

    it "does not flag regular comments" do
      expect_no_offenses(<<~RUBY)
        # TODO: clean up later
      RUBY
    end
  end
end
