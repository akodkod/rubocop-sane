# frozen_string_literal: true

RSpec.describe RuboCop::Sane::Plugin do
  let(:plugin) { described_class.new }

  describe "#about" do
    it "returns plugin information" do
      about = plugin.about

      expect(about.name).to eq("rubocop-sane")
      expect(about.version).to eq(RuboCop::Sane::VERSION)
      expect(about.homepage).to eq("https://github.com/akodkod/rubocop-sane")
      expect(about.description).to eq("Sane RuboCop cops for modern Ruby development.")
    end
  end

  describe "#supported?" do
    let(:context_class) { Struct.new(:engine) }

    it "returns true for rubocop engine" do
      context = context_class.new(:rubocop)
      expect(plugin.supported?(context)).to be(true)
    end

    it "returns false for other engines" do
      context = context_class.new(:other)
      expect(plugin.supported?(context)).to be(false)
    end
  end

  describe "#rules" do
    let(:context_class) { Struct.new(:engine) }

    it "returns rules configuration" do
      context = context_class.new(:rubocop)
      rules = plugin.rules(context)

      expect(rules.type).to eq(:path)
      expect(rules.config_format).to eq(:rubocop)
      expect(rules.value).to eq(RuboCop::Sane::CONFIG_DEFAULT)
    end
  end
end
