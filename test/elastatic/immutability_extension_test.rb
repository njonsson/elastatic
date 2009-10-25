require 'test/unit'
unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
end
require_relative '../../lib/elastatic/friendly_tests_extension'
require_relative '../../lib/elastatic/assertions_extension'
require_relative '../../lib/elastatic/immutability_extension'

class Elastatic::ImmutabilityExtensionTest < Test::Unit::TestCase
  
  class AnObject
    
    def initialize
      @fixnum = 123
      @string = 'foo'
    end
    
    def a_fixnum_return_value
      @fixnum
    end
    
    def a_string_return_value
      @string
    end
    
  end
  
  test 'should make a String return value immutable' do
    an_object = AnObject.new
    assert_equal 'foo', an_object.a_string_return_value
    AnObject.immutable :a_string_return_value
    an_object.a_string_return_value.gsub! 'o', 'x'
    assert_equal 'foo', an_object.a_string_return_value
  end
  
  test 'should have no effect on a Fixnum return value' do
    an_object = AnObject.new
    assert_equal 123, an_object.a_fixnum_return_value
    assert_nothing_raised do
      AnObject.immutable :a_fixnum_return_value
    end
    assert_equal 123, an_object.a_fixnum_return_value
  end
  
end
