# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::NoMethodCallAfterEnd, :config do
  context "with if/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        if condition
          value
        end.foo
           ^ Do not call methods directly after `end`.
      RUBY
    end

    it "registers an offense for safe navigation after end" do
      expect_offense(<<~RUBY)
        if condition
          value
        end&.foo
           ^^ Do not call methods directly after `end`.
      RUBY
    end

    it "does not register an offense for normal if" do
      expect_no_offenses(<<~RUBY)
        if condition
          value
        end
      RUBY
    end
  end

  context "with case/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        case value
        when 1
          :one
        end.to_s
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with block do/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        array.map do |item|
          transform(item)
        end.compact
           ^ Do not call methods directly after `end`.
      RUBY
    end

    it "registers an offense for chained method calls after end" do
      expect_offense(<<~RUBY)
        array.map do |item|
          transform(item)
        end.compact.first
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with begin/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        begin
          risky_operation
        rescue
          fallback
        end.process
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with while/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        while condition
          accumulate
        end.result
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with until/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        until done
          work
        end.result
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with def/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        def foo
          :bar
        end.call
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with class/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        class Foo
        end.name
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with module/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        module Foo
        end.name
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "with for/end" do
    it "registers an offense for method call after end" do
      expect_offense(<<~RUBY)
        for i in 1..10
          puts i
        end.inspect
           ^ Do not call methods directly after `end`.
      RUBY
    end
  end

  context "when method call is not after end" do
    it "does not register an offense for regular method calls" do
      expect_no_offenses(<<~RUBY)
        foo.bar
        obj.method_name
        array.map { |x| x * 2 }.compact
      RUBY
    end

    it "does not register an offense for brace blocks" do
      expect_no_offenses(<<~RUBY)
        array.map { |item| transform(item) }.compact
      RUBY
    end

    it "does not register an offense for parenthesized expressions" do
      expect_no_offenses(<<~RUBY)
        (office.auto_renew_mode || auto_renew_mode).to_sym
        ids.concat((min_id..max_id).to_a)
        (a + b).to_s
      RUBY
    end
  end
end
