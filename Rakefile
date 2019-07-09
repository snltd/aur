# frozen_string_literal: true

require 'yard'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

task default: :test

Rake::TestTask.new(test: :rubocop) do |t|
  t.pattern = 'spec/aur/**/*_spec.rb'
  t.warning = false
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/aur/**/*.rb']
end
