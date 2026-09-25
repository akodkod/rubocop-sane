# Changelog

## Unreleased

### Fixed

- Fix `Sane/ConditionalAssignmentAllowTernary` to report setter assignments from
  `if/else` and `case` expressions, including explicit receivers such as
  `self.admin` and `record.name`. Preserve existing variable assignment behavior
  and continue allowing ternaries and ordinary method calls with conditional
  arguments. Add regression specs for these cases.
