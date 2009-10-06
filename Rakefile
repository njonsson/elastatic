require 'rake'
Rake.application.options.trace = true
require 'rake/rdoctask'
begin
  require 'rcov/rcovtask'
  RCOV_MISSING = false
rescue LoadError
  RCOV_MISSING = true
  $stderr.puts '*' * 68
  $stderr.puts 'Test coverage tasks are not available because RCov is not installed.'
  $stderr.puts "To install RCov, type 'gem install rcov'."
  $stderr.puts '*' * 68
end
require File.expand_path("#{File.dirname __FILE__}/lib/elastatic/require_relative_extension")
require_relative 'lib/site'

def announce(message, options={})
  options[:done] = ' done' unless options.include?(:done)
  print "#{message}"
  yield
  puts options[:done] unless options[:done].nil?
end

def in_project_directory
  variable_name = 'PROJECT_DIRECTORY'
  project_directory = ENV[variable_name]
  unless project_directory
    $stderr.puts "*** Error: You must specify the #{variable_name} variable"
    exit 1
  end
  Dir.chdir project_directory do
    yield
  end
end

TESTS_FILESPEC = File.expand_path("#{File.dirname __FILE__}/test/**/*_test.rb")
def with_test_files
  first = true
  Dir.glob TESTS_FILESPEC do |f|
    yield f, first
    first = false
  end
end

task :default => :test

namespace :site do
  desc 'Build the site'
  task :build => :clobber do
    in_project_directory do
      announce "Building site at #{Dir.pwd} ..." do
        Site.new.build!
      end
    end
  end
  
  desc "Delete the '#{Site::OUTPUT_DIRECTORY}' directory"
  task :clobber do
    in_project_directory do
      announce 'Clobbering output ...' do
        Site.new.clobber!
      end
    end
  end
end

desc 'Run automated tests'
task :test do
  announce "Running tests ...\n", :done => nil do
    with_test_files do |f, first|
      require File.join(File.dirname(f), File.basename(f, '.rb'))
    end
  end
end

namespace :test do
  desc 'Run each automated test file in its own Ruby process'
  task :individually do
    def accumulate_counts!(output_line, statistics)
      match_data = output_line.match(/^(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors$/)
      return false unless match_data
      statistics[:tests]      += match_data[1].to_i
      statistics[:assertions] += match_data[2].to_i
      statistics[:failures]   += match_data[3].to_i
      statistics[:errors]     += match_data[4].to_i
      true
    end
    
    def accumulate_duration!(output_line, statistics)
      match_data = output_line.match(/^Finished in (\d+(\.\d+)?) seconds\.$/)
      return false unless match_data
      statistics[:duration] += match_data[1].to_f
      true
    end
    
    announce "Running each test file individually ...\n", :done => nil do
      statistics = {:duration   => 0.0,
                    :tests      => 0,
                    :assertions => 0,
                    :failures   => 0,
                    :errors     => 0}
      with_test_files do |f, first|
        puts '-' * 67 unless first
        IO.popen %Q(/usr/bin/env ruby "#{f}") do |stdout|
          until stdout.eof? do
            line = stdout.gets.chomp
            puts line
            next if accumulate_counts!(line, statistics)
            accumulate_duration! line, statistics
          end
        end
      end
      puts
      puts "=TOTALS#{'=' * 60}"
      puts
      puts "Finished in #{statistics[:duration]} seconds."
      puts
      puts "#{statistics[:tests]} tests, "           +
           "#{statistics[:assertions]} assertions, " +
           "#{statistics[:failures]} failures, "     +
           "#{statistics[:errors]} errors"
    end
  end
  
  unless RCOV_MISSING
    desc 'Create a code coverage report for the tests in test'
    Rcov::RcovTask.new :coverage do |rcov|
      rcov.output_dir = 'test_coverage'
      rcov.test_files = TESTS_FILESPEC
      rcov.verbose    = true
    end
  end
end

namespace :doc do
  Rake::RDocTask.new :rdoc do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.title    = 'Elastatic'
    rdoc.rdoc_files.include 'README.rdoc'
    rdoc.rdoc_files.include 'MIT-LICENSE'
    rdoc.rdoc_files.include 'build'
    rdoc.rdoc_files.include 'lib/**/*.rb'
    rdoc.rdoc_files.exclude 'lib/elastatic/friendly_tests_extension.rb'
    rdoc.options << '--line-numbers' << '--inline-source'
  end
end
