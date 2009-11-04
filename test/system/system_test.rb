require 'test/unit'
unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
end
require_relative '../../lib/elastatic/friendly_tests_extension'

class SystemTest < Test::Unit::TestCase
  
  def setup
    @here_path = File.expand_path(File.dirname(__FILE__))
    system %Q(rm -fr "#{@here_path}/test_project/_output")
    execute_discardng_stdout %Q("#{@here_path}/../../build" ) +
                             %Q("#{@here_path}/test_project")
  end
  
  test 'should build static site with expected content, markup and assets' do
    test  = %Q("#{@here_path}/test_project/_output")
    truth = %Q("#{@here_path}/truth")
    assert_equal true,
                 system("diff --unified --recursive #{test} #{truth}"),
                 "'diff' found differences between #{test} and #{truth}"
  end
  
private
  
  def execute_discardng_stdout(command)
    IO.popen command do |stdout|
      stdout.gets
    end
    self
  end
  
end
