# frozen_string_literal: true

RSpec.describe RuboCop::Sane do
  it "has a version number" do
    expect(RuboCop::Sane::VERSION).not_to be_nil
  end

  it "has a project root" do
    expect(RuboCop::Sane::PROJECT_ROOT).to be_a(Pathname)
  end

  it "has a config default path" do
    expect(RuboCop::Sane::CONFIG_DEFAULT).to be_a(Pathname)
    expect(RuboCop::Sane::CONFIG_DEFAULT.to_s).to end_with("config/default.yml")
  end
end
