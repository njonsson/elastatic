require 'test/unit'
unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
end
require_relative '../../lib/elastatic/friendly_tests_extension'
unless :a_symbol.respond_to?(:to_proc)
  require_relative '../../lib/elastatic/to_proc_extension'
end

class Elastatic::ToProcExtensionTest < Test::Unit::TestCase
  
  test 'should enable &:method_name syntax on methods that take a block' do
    assert_equal %w(FOO BAR), %w(foo bar).collect(&:upcase)
  end
  
  test 'should not affect block syntax on methods that take a block' do
    assert_equal %w(FOO BAR), %w(foo bar).collect { |s| s.upcase }
  end
  
end
