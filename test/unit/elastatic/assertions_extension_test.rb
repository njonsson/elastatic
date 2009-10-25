require 'test/unit'
unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/../../../lib/elastatic/require_relative_extension")
end
require_relative '../../../lib/elastatic/friendly_tests_extension'
require_relative '../../../lib/elastatic/assertions_extension'

class Elastatic::AssertionsExtensionTest < Test::Unit::TestCase
  
  test 'should pass when the expression does not change inside the block' do
    foo = 123
    assert_unchanged 'foo' do
      assert_equal 123, foo
    end
    assert_equal 123, foo
  end
  
  test 'should fail when the value of the expression changes inside the block' do
    foo = 456
    assert_equal 456, foo
    assert_raise Elastatic::AssertionsExtension::ASSERTION_FAILED_ERROR do
      assert_unchanged 'foo' do
        foo = 789
      end
    end
    assert_equal 789, foo
  end
  
  test 'should fail when the expression mutates inside the block' do
    foo = 'foo'
    assert_equal 'foo', foo
    assert_raise Elastatic::AssertionsExtension::ASSERTION_FAILED_ERROR do
      assert_unchanged 'foo' do
        foo.gsub! 'o', 'x'
      end
    end
    assert_equal 'fxx', foo
  end
  
end
