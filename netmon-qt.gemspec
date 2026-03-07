# frozen_string_literal: true

require_relative "lib/netmon-qt/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-netmon-qt"
  spec.version = NetmonQt::VERSION
  spec.authors = ["John Doe"]
  spec.email = ["johndoe@example.com"]

  spec.summary = "A simple network monitor on Linux."
  spec.description = "A simple network monitor on Linux."
  spec.homepage = "https://github.com/souk4711/ruby-netmon-qt"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/souk4711/ruby-netmon-qt"
  spec.metadata["changelog_uri"] = "https://github.com/souk4711/ruby-netmon-qt"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ruby-qt6-qtwidgets", "~> 6.0.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
