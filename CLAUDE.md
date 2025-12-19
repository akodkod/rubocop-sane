# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

rubocop-sane is a RuboCop extension gem that provides custom cops for enforcing sensible Ruby coding conventions. It uses the LintRoller plugin system for integration with RuboCop.

## Common Commands

```bash
# Install dependencies
bin/setup

# Run all tests
bundle exec rake spec

# Run a single test file
bundle exec rspec spec/rubocop/cop/sane/disallow_methods_spec.rb

# Run a single test by line number
bundle exec rspec spec/rubocop/cop/sane/disallow_methods_spec.rb:42

# Run RuboCop linting
bundle exec rubocop

# Run all checks (tests + rubocop)
bundle exec rake

# Interactive console
bin/console
```

## Architecture

### Entry Point & Plugin System

- `lib/rubocop-sane.rb` - Main entry point that loads all components
- `lib/rubocop/sane/plugin.rb` - LintRoller plugin that integrates with RuboCop's plugin system
- `config/default.yml` - Default cop configurations

### Cop Structure

All cops live under `lib/rubocop/cop/sane/` and follow RuboCop's cop pattern:
- Inherit from `RuboCop::Cop::Base`
- Use `extend AutoCorrector` for auto-fix support
- Implement `on_*` methods (e.g., `on_send`, `on_if`) to visit AST nodes

### Current Cops

1. **DisallowMethods** - Configurable cop for method replacements and prohibitions with auto-correct
2. **ConditionalAssignmentAllowTernary** - Enforces assignment inside conditions but allows ternary operators
3. **EmptyLineBeforeComment** - Requires blank line before comments (except after block starts, class/method definitions, etc.)
4. **EmptyLinesAroundMultilineBlock** - Enforces empty lines around multiline if/case/block statements

### Testing

Tests use RuboCop's `ExpectOffense` helper which provides a DSL for testing cop behavior:
```ruby
expect_offense(<<~RUBY)
  foo = if bar
  ^^^^^^^^^^^^ Move the assignment inside the `if` branch.
    1
  else
    2
  end
RUBY
```

The `^` characters mark where the offense should be detected.

## Adding a New Cop

1. Create cop file in `lib/rubocop/cop/sane/your_cop.rb`
2. Add require in `lib/rubocop/cop/sane_cops.rb`
3. Add configuration in `config/default.yml`
4. Create spec in `spec/rubocop/cop/sane/your_cop_spec.rb`
