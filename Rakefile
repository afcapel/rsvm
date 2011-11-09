require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'

task :default => ['db:drop', 'db:migrate', :test]

desc "Run unit tests"
Rake::TestTask.new do |test|
   test.ruby_opts  << "-w"  # .should == true triggers a lot of warnings
   test.libs       << "test"
   test.test_files =  Dir[ "test/**/*_test.rb"]
   test.verbose    =  false
end
