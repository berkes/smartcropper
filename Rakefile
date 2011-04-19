# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "croptoelie"
  gem.homepage = "http://github.com/berkes/croptoelie"
  gem.license = "MIT"
  gem.summary = %Q{Content aware cropper.}
  gem.description = %Q{Crops images based on entropy: leaving the most interesting part intact. Don't expect this to be a replacement for human cropping, it is an algorythm and not an extremely smart one at that :). Best results achieved in combination with scaling: the cropping is then only used to square the image, cutting off the least interesting part. The trimming simply chops off te edge that is least interesting, and continues doing so, untill it reached the requested size.}
  gem.email = "ber@webschuur.com"
  gem.authors = ["Bèr Kessels"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  
  gem.add_runtime_dependency 'rmagick', '> 2.11.0'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "croptoelie #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
