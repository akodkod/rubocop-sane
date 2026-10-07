# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::ProhibitedCommentCharacters, :config do
  it "reports a semicolon in a standalone comment without autocorrection" do
    expect_offense(<<~RUBY)
      # Load; update
            ^ Do not use ";" in comments. Stay a human.
    RUBY

    expect_no_corrections
  end

  it "reports semicolons in inline comments but not code or strings" do
    expect_offense(<<~RUBY)
      foo = ";"; bar # Load; update
                           ^ Do not use ";" in comments. Stay a human.
    RUBY
  end

  it "reports every occurrence across consecutive comment lines" do
    expect_offense(<<~RUBY)
      # ;;
         ^ Do not use ";" in comments. Stay a human.
        ^ Do not use ";" in comments. Stay a human.
      # ;
        ^ Do not use ";" in comments. Stay a human.
    RUBY
  end

  it "reports characters in embedded documentation" do
    expect_offense(<<~RUBY)
      =begin
      Load;
          ^ Do not use ";" in comments. Stay a human.
      update;
            ^ Do not use ";" in comments. Stay a human.
      =end
    RUBY
  end

  it "preserves accurate positions after Unicode characters" do
    expect_offense(<<~RUBY)
      # Café;
            ^ Do not use ";" in comments. Stay a human.
    RUBY
  end

  it "allows other punctuation and ignores comment-like strings" do
    expect_no_offenses(<<~RUBY)
      # Load, update. Done!
      #
      text = "# ;"
    RUBY
  end

  it "handles files without comments" do
    expect_no_offenses("foo\n")
  end

  context "with custom prohibited characters" do
    let(:cop_config) { { "ProhibitedCharacters" => [".", "!", "—", "#", "="] } }

    it "matches literal punctuation and Unicode characters" do
      expect_offense(<<~RUBY)
        # Hi!
            ^ Do not use "!" in comments. Stay a human.
        # Hi.
            ^ Do not use "." in comments. Stay a human.
        # Hi—
            ^ Do not use "—" in comments. Stay a human.
      RUBY
    end

    it "replaces the default list" do
      expect_no_offenses("# Load; update\n")
    end

    it "excludes the hash delimiter but checks hashes inside comment text" do
      expect_offense(<<~RUBY)
        # A # tag
            ^ Do not use "#" in comments. Stay a human.
      RUBY
    end

    it "excludes embedded documentation delimiters but checks its body" do
      expect_offense(<<~RUBY)
        =begin
        # Heading
        ^ Do not use "#" in comments. Stay a human.
        a = b
          ^ Do not use "=" in comments. Stay a human.
        =end
      RUBY
    end
  end

  context "with an empty prohibited list" do
    let(:cop_config) { { "ProhibitedCharacters" => [] } }

    it "allows all comment characters" do
      expect_no_offenses("# Load; update!\n")
    end
  end
end
