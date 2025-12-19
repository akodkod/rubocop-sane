# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  # NOTE: 100% branch coverage is impractical for AST-walking code due to
  # defensive programming for edge cases that can't occur in valid Ruby.
  # 95% line, 80% branch provides strong coverage for realistic scenarios.
  minimum_coverage line: 95, branch: 80
  add_filter "/spec/"
end

require "rubocop-sane"
require "rubocop/rspec/support"

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense

  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
