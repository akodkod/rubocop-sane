# frozen_string_literal: true

require_relative "lib/rubocop/sane/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-sane"
  spec.version = RuboCop::Sane::VERSION
  spec.authors = ["Andrew Kodkod"]
  spec.email = ["678665+akodkod@users.noreply.github.com"]

  spec.summary = "Sane RuboCop cops for modern Ruby development"
  spec.description = "A collection of RuboCop cops that enforce sensible coding conventions"
  spec.homepage = "https://github.com/akodkod/rubocop-sane"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["default_lint_roller_plugin"] = "RuboCop::Sane::Plugin"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(["git", "ls-files", "-z"], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".github", "Gemfile")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "lint_roller", "~> 1.1"
  spec.add_dependency "rubocop", ">= 1.48.0", "< 2.0"
end
