require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'
require 'rake/clean'

task :default => :test

LIB_EXT = RbConfig::CONFIG['DLEXT']

desc "Run unit tests"
Rake::TestTask.new do |test|
  test.ruby_opts  << "-w"  # .should == true triggers a lot of warnings
  test.libs       << "test"
  test.test_files =  Dir[ "test/**/*_test.rb"]
  test.verbose    =  false
end

# rule to build the extension: this says
# that the extension should be rebuilt
# after any change to the files in ext
file "lib/libsvm/libsvm.#{LIB_EXT}" =>
  Dir.glob("ext/libsvm/*{.rb,.c}") do
    Dir.chdir("ext/libsvm") do
      # this does essentially the same thing
      # as what rubygems does
      ruby "extconf.rb"
      sh "make"
  end
  
  cp "ext/libsvm/libsvm.#{LIB_EXT}", "lib/libsvm/libsvm.#{LIB_EXT}"
end

# make the :test task depend on the shared
# object, so it will be built automatically
# before running the tests
task :test => "lib/libsvm/libsvm.#{LIB_EXT}"

# use 'rake clean' and 'rake clobber' to
# easily delete generated files
CLEAN.include("ext/**/*{.o,.log,.#{LIB_EXT}}")
CLEAN.include('ext/**/Makefile')
CLOBBER.include("lib/**/*.#{LIB_EXT}")