# Changelog

## Unreleased

### Added

- Add `Sane/ProhibitedCommentCharacters` to report configurable characters anywhere
  in comment text, with `;` prohibited by default.
- Add `Sane/TrailingCommentPeriod` with autocorrection to remove a comment's final
  period unless an earlier period appears in the same comment block.

### Fixed

- Fix `Sane/ConditionalAssignmentAllowTernary` to report setter assignments from
  `if/else` and `case` expressions, including explicit receivers such as
  `self.admin` and `record.name`. Preserve existing variable assignment behavior
  and continue allowing ternaries and ordinary method calls with conditional
  arguments. Add regression specs for these cases.
