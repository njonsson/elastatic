require 'test/unit'
require File.expand_path("#{File.dirname __FILE__}/../../vendor/mocha")
require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")

class Elastatic::RequireRelativeExtensionTest < Test::Unit::TestCase
  
  def test_should_require_the_expected_path_when_require_relative_is_called_on_Kernel
    Kernel.expects(:require).
           with File.expand_path("#{File.dirname __FILE__}/foo/bar")
    Kernel.require_relative 'foo/bar'
  end
  
  def test_should_require_the_expected_path_when_require_relative_is_called_on_Kernel_while_in_a_different_working_directory
    Dir.chdir '..' do
      Kernel.expects(:require).
             with File.expand_path("#{File.dirname __FILE__}/foo/bar")
      Kernel.require_relative 'foo/bar'
    end
  end
  
  def test_should_require_the_expected_path_when_require_relative_is_called_as_an_instance_method
    Kernel.expects(:require).
           with File.expand_path("#{File.dirname __FILE__}/../../baz/bat")
    require_relative '../../baz/bat'
  end
  
  def test_should_require_the_expected_path_when_require_relative_is_called_as_an_instance_method_while_in_a_different_working_directory
    Dir.chdir '..' do
      Kernel.expects(:require).
             with File.expand_path("#{File.dirname __FILE__}/../../baz/bat")
      require_relative '../../baz/bat'
    end
  end
  
  def test_should_require_the_expected_path_when_require_relative_is_called_as_a_class_method
    Kernel.expects(:require).
           with File.expand_path("#{File.dirname __FILE__}/./pwop/../ding")
    self.class.require_relative './pwop/../ding'
  end
  
  def test_should_require_the_expected_path_when_require_relative_is_called_as_a_class_method_while_in_a_different_working_directory
    Dir.chdir '..' do
      Kernel.expects(:require).
             with File.expand_path("#{File.dirname __FILE__}/./pwop/../ding")
      self.class.require_relative './pwop/../ding'
    end
  end
  
end
