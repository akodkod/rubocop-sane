# Rubocop::Sane

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rubocop/sane`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubocop-sane. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rubocop-sane/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rubocop::Sane project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rubocop-sane/blob/main/CODE_OF_CONDUCT.md).

## Model section comments

`Sane/ModelSections` requires populated, unique section headings in this order:
Includes, Associations, Validations, Enumerables, Scopes. Only sections with
matching declarations are required. Other sections, such as Constants or
Callbacks, may appear between them. Both headings and declarations must follow
the order. The cop reports violations without autocorrecting, even with `-A`.

```ruby
class Member < ApplicationRecord
  # Includes
  include Versioning
  extend ArrayEnum

  # Associations
  belongs_to :call_center

  # Enumerables
  array_enum colors: { red: 1 }

  # Scopes
  def self.with_ticket_id(id)
    where(ticket_id: id)
  end
end
```

The cop is enabled by default when using the plugin:

```yaml
plugins:
  - rubocop-sane

Sane/ModelSections:
  ScopeMethodPatterns:
    - '^with_'
    - '^without_'
```

`ScopeMethodPatterns` is a replacement list of Ruby regular-expression strings.
Use `[]` to disable inference from class method names. `scope` and `default_scope`
always require Scopes; other class methods explicitly placed under Scopes also
populate that section. Both `def self.method` and `class << self` are supported.

Includes recognizes `include`, `extend`, and `prepend`. Associations recognizes
`belongs_to`, `has_one`, `has_many`, and `has_and_belongs_to_many`. Validations
recognizes `validate`, `validates`, `validates!`, and `validates_*` macros.
Enumerables recognizes `enum` and `array_enum`. Active Storage attachment macros
are not classified as Associations.

Headings must be standalone, case-sensitive comments, for example
`# Associations`. Blank lines and descriptive comments may precede declarations.
Standalone title-style comments end the preceding section: each word starts
with an uppercase letter and contains letters only, with `/` and `&` permitted
as separate words (for example, `# Getters / Setters`). Prose such as
`# These associations belong to the member.` is not a heading. Repeating a
heading to resume an earlier section is an offense; unused headings are also
reported.

The default file filters inspect `**/app/models/**/*.rb` and exclude
`**/app/models/concerns/**/*.rb`, regardless of the class's superclass. Standard
RuboCop `Include` and `Exclude` settings can customize these filters. Each class
is checked independently. Inspection covers direct declarations, macro calls
with blocks, and modifier conditions. Method bodies, macro block bodies,
general conditional blocks, and wrappers such as `with_options` are not
searched for declarations belonging to the enclosing class.
