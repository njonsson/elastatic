require 'test/unit'
require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
require_relative { '../../lib/elastatic/friendly_tests_extension' }
require_relative { '../../lib/elastatic/to_proc_extension' }

class Elastatic::ToProcExtensionTest < Test::Unit::TestCase
  
  test 'should enable &:method_name syntax on methods that take a block' do
    assert_equal %w(FOO BAR), %w(foo bar).collect(&:upcase)
  end
  
  test 'should not affect block syntax on methods that take a block' do
    assert_equal %w(FOO BAR), %w(foo bar).collect { |s| s.upcase }
  end
  
end
