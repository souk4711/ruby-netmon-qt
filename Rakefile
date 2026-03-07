# frozen_string_literal: true

require "bundler/gem_tasks"
_ = Gem::Specification.load("netmon-qt.gemspec")

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

task default: %i[spec]
