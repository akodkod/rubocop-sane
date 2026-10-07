# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::TrailingCommentPeriod, :config do
  it "removes the final period from a single sentence" do
    expect_offense(<<~RUBY)
      # A comment.
                 ^ Remove the trailing period from a comment without earlier periods
    RUBY

    expect_correction("# A comment\n")
  end

  it "removes the final period from a wrapped sentence" do
    expect_offense(<<~RUBY)
      # A comment
      # on two lines.
                    ^ Remove the trailing period from a comment without earlier periods
    RUBY

    expect_correction(<<~RUBY)
      # A comment
      # on two lines
    RUBY
  end

  it "preserves comments with multiple sentences on one line" do
    expect_no_offenses("# First sentence. Second sentence.\n")
  end

  it "preserves periods in a block with multiple sentences" do
    expect_no_offenses(<<~RUBY)
      # First sentence.
      # Second sentence.
    RUBY
  end

  it "preserves internal periods when the block has no final period" do
    expect_no_offenses(<<~RUBY)
      # First sentence.
      # Second sentence
    RUBY
  end

  it "allows any earlier dot, including URLs, abbreviations, and ellipses" do
    expect_no_offenses(<<~RUBY)
      # See example.com.

      # Ask Dr. Ruby.

      # Waiting...
    RUBY
  end

  it "allows a dot on an earlier line of the same block" do
    expect_no_offenses(<<~RUBY)
      # See example.com
      # for details.
    RUBY
  end

  it "starts a new block after a blank line" do
    expect_offense(<<~RUBY)
      # First. Second.

      # A comment.
                 ^ Remove the trailing period from a comment without earlier periods
    RUBY

    expect_correction("# First. Second.\n\n# A comment\n")
  end

  it "starts a new block after code" do
    expect_offense(<<~RUBY)
      # First. Second.
      foo
      # A comment.
                 ^ Remove the trailing period from a comment without earlier periods
    RUBY

    expect_correction("# First. Second.\nfoo\n# A comment\n")
  end

  it "checks adjacent inline comments independently of code and each other" do
    expect_offense(<<~RUBY)
      foo.bar # First. Second.
      foo.bar # A comment.
                         ^ Remove the trailing period from a comment without earlier periods
    RUBY

    expect_correction("foo.bar # First. Second.\nfoo.bar # A comment\n")
  end

  it "does not join inline comments to adjacent standalone comments" do
    expect_offense(<<~RUBY)
      foo # First. Second.
      # A comment.
                 ^ Remove the trailing period from a comment without earlier periods
      foo # A comment.
                     ^ Remove the trailing period from a comment without earlier periods
      # First. Second.
    RUBY

    expect_correction("foo # First. Second.\n# A comment\nfoo # A comment\n# First. Second.\n")
  end

  it "preserves indentation, non-ASCII text, and trailing whitespace" do
    expect_offense(<<~RUBY)
      def foo
        # Café.\s\s
              ^ Remove the trailing period from a comment without earlier periods
      end
    RUBY

    expect_correction("def foo\n  # Café  \nend\n")
  end

  it "checks embedded documentation comments" do
    expect_offense(<<~RUBY)
      =begin
      A comment
      on two lines.
                  ^ Remove the trailing period from a comment without earlier periods
      =end
    RUBY

    expect_correction("=begin\nA comment\non two lines\n=end\n")
  end

  it "preserves embedded documentation with earlier dots" do
    expect_no_offenses("=begin\nFirst sentence.\nSecond sentence.\n=end\n")
  end

  it "allows comments without a final period and ignores strings" do
    expect_no_offenses(<<~RUBY)
      # A comment
      #
      # Question?
      foo = "# A string."
    RUBY
  end

  it "handles files without comments" do
    expect_no_offenses("foo\n")
  end

  it "handles a comment containing only a period" do
    expect_offense(<<~RUBY)
      # .
        ^ Remove the trailing period from a comment without earlier periods
    RUBY

    expect_correction("# \n")
  end
end
