# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sane::ModelSections, :config do
  it "accepts the sections used by Job, including unrelated sections and explicit scope methods" do
    expect_no_offenses(<<~RUBY)
      class Job < ApplicationRecord
        # Includes
        include Versioning
        extend Helpers
        prepend Overrides

        # Constants
        ATTRIBUTES = [:name].freeze
        # Extensions
        has_one_attached :file
        store_accessor :properties, :external_id
        # Associations
        # A description of the association.
        belongs_to :company
        has_many :tickets do
          def with_number
            where(number: 1)
          end
        end
        # Validations
        validates :number,
          presence: true
        validate :check_number
        validates_presence_of :name
        # Enumerables
        enum :status, { active: 0 }
        # Scopes
        scope :active, -> { where(status: :active) }
        def self.with_status(status)
          where(status: status)
        end
        def self.order_by_name
          order(:name)
        end
      end
    RUBY
  end

  it "accepts Member's array enum and class-method-only scopes" do
    expect_no_offenses(<<~RUBY)
      class Member < CustomBase
        # Includes
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
    RUBY
  end

  it "reports missing headings on calls and method names" do
    expect_offense(<<~RUBY)
      class Record < ApplicationRecord
        belongs_to :note
        ^^^^^^^^^^ Place this declaration under `# Associations`.
        enum :status, { active: 0 }
        ^^^^ Place this declaration under `# Enumerables`.
        def self.with_id(id)
                 ^^^^^^^ Place this declaration under `# Scopes`.
        end
      end
    RUBY
  end

  it "reports duplicate populated headings" do
    expect_offense(<<~RUBY)
      class TicketRevisionResponse < ApplicationRecord
        # Includes
        include Versioning
        # Includes
        ^^^^^^^^^^ Duplicate `# Includes` section.
        include Broadcastable
      end
    RUBY
  end

  it "reports both reversed headings and reversed declarations" do
    expect_offense(<<~RUBY)
      class Note < ApplicationRecord
        # Enumerables
        enum :action, { created: 0 }
        # Validations
        ^^^^^^^^^^^^^ Move `# Validations` before `# Enumerables`.
        validates :text, presence: true
        ^^^^^^^^^ Move this Validations declaration before Enumerables declarations.
      end
    RUBY
  end

  it "checks declarations independently of correctly ordered headings" do
    expect_offense(<<~RUBY)
      class Note
        # Associations
        belongs_to :author
        enum :status, { active: 0 }
        ^^^^ Place this declaration under `# Enumerables`.
        # Validations
        validates :text, presence: true
        ^^^^^^^^^ Move this Validations declaration before Enumerables declarations.
        # Enumerables
        ^^^^^^^^^^^^^ Remove empty `# Enumerables` section.
      end
    RUBY
  end

  it "ends a section at an unrelated title heading" do
    expect_offense(<<~RUBY)
      class Note
        # Includes
        include Versioning
        # Constants
        VALUE = 1
        include Broadcastable
        ^^^^^^^ Place this declaration under `# Includes`.
      end
    RUBY
  end

  it "rejects empty and incorrectly cased headings" do
    expect_offense(<<~RUBY)
      class Note
        # Includes
        ^^^^^^^^^^ Remove empty `# Includes` section.
        # associations
        belongs_to :author
        ^^^^^^^^^^ Place this declaration under `# Associations`.
        # Scopes
        ^^^^^^^^ Remove empty `# Scopes` section.
      end
    RUBY
  end

  it "supports modifiers, explicit self, default_scope and block validations" do
    expect_no_offenses(<<~RUBY)
      class Note
        # Includes
        include Versioning if enabled?
        extend Helpers unless disabled?
        # Associations
        self.has_one :author
        has_and_belongs_to_many :tags
        # Validations
        validates! :name, presence: true
        validates_each(:name) { |record, attr, value| check(value) }
        validates_with Validator
        # Scopes
        default_scope { order(:id) }
      end
    RUBY
  end

  it "handles singleton class methods and comments" do
    expect_offense(<<~RUBY)
      class Note
        class << self
          def without_author
              ^^^^^^^^^^^^^^ Place this declaration under `# Scopes`.
          end
          # Scopes
          def with_author
          end
          def ordered
          end
        end
      end
    RUBY
  end

  it "does not classify calls inside singleton classes as model macros" do
    expect_no_offenses(<<~RUBY)
      class Note
        class << self
          include Helpers
        end
      end
    RUBY
  end

  it "isolates nested bodies and ignores non-declaration code" do
    expect_no_offenses(<<~RUBY)
      module Models
        class Note
          # Includes
          include Versioning
          def work
            # Associations
            belongs_to :fake
          end
          with_options optional: true do
            # Associations
            belongs_to :author
          end
          if enabled?
            belongs_to :author
          end
          other.include Helpers
          def other.with_id
          end
          class Nested
            # Associations
            belongs_to :author
          end
        end
        class Empty
        end
        class Other
          # Includes
          include Versioning
        end
      end
    RUBY
  end

  it "does not interpret inline comments or prose as headings" do
    expect_no_offenses(<<~RUBY)
      class Note
        # Associations

        # These associations belong to the note
        belongs_to :author # Scopes
        has_many :tags
      end
    RUBY
  end

  context "with custom scope patterns" do
    let(:cop_config) { { "ScopeMethodPatterns" => ["^ordered$"] } }

    it "replaces the default patterns" do
      expect_offense(<<~RUBY)
        class Note
          def self.with_id
          end
          def self.ordered
                   ^^^^^^^ Place this declaration under `# Scopes`.
          end
        end
      RUBY
    end
  end

  context "with scope inference disabled" do
    let(:cop_config) { { "ScopeMethodPatterns" => [] } }

    it "allows unheaded class methods and explicitly grouped scope methods" do
      expect_no_offenses(<<~RUBY)
        class Note
          def self.with_id
          end
          # Scopes
          def self.ordered
          end
        end
      RUBY
    end
  end

  it "does not offer autocorrection" do
    expect(described_class.support_autocorrect?).to be(false)
  end
end
