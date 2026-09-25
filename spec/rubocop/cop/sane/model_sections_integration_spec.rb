# frozen_string_literal: true

require "json"
require "open3"
require "tmpdir"
require "fileutils"

RSpec.describe RuboCop::Cop::Sane::ModelSections do
  it "loads through the plugin, filters files, and leaves offenses unchanged with -A" do
    Dir.mktmpdir("model-sections") do |directory|
      paths = ["app/models/note.rb", "app/models/concerns/helper.rb", "app/services/helper.rb"]
      source = "class Note < CustomBase\n  belongs_to :author\nend\n"
      paths.each do |path|
        filename = File.join(directory, path)
        FileUtils.mkdir_p(File.dirname(filename))
        File.write(filename, source)
      end
      File.write(File.join(directory, ".rubocop.yml"), "AllCops:\n  NewCops: enable\n")

      output, errors, status = run_plugin(directory)
      expect(status.exitstatus).to eq(1), errors
      expect(output).not_to be_empty, errors
      result = JSON.parse(output)
      offenses = result.fetch("files").select { |file| file.fetch("offenses").any? }
      expect(offenses.size).to eq(1), "#{output}\n#{errors}"
      expect(offenses.first.fetch("path")).to end_with("app/models/note.rb")
      expect(offenses.first.fetch("offenses").first.fetch("cop_name")).to eq("Sane/ModelSections")
      paths.each { |path| expect(File.read(File.join(directory, path))).to eq(source) }
    end
  end

  def run_plugin(directory)
    Open3.capture3(
      { "RUBOCOP_CACHE_ROOT" => File.join(directory, "cache") },
      RbConfig.ruby, "-I", RuboCop::Sane::PROJECT_ROOT.join("lib").to_s,
      Gem.bin_path("rubocop", "rubocop"), "--plugin", "rubocop-sane",
      "--config", File.join(directory, ".rubocop.yml"), "--only", "Sane/ModelSections",
      "--cache", "false", "--format", "json", "--autocorrect-all", directory,
      chdir: directory,
    )
  end
end
