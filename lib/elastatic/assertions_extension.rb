require 'test/unit'

module Elastatic; end

module Elastatic::AssertionsExtension
  
  # Accommodate Ruby 1.9 and earlier.
  ASSERTION_FAILED_ERROR = Test::Unit::AssertionFailedError rescue MiniTest::Assertion
  
  def assert_unchanged(expression, &block)
    value_before = eval(expression, block.binding)
    value_before = value_before.dup rescue value_before
    block.call
    value_after = eval(expression, block.binding)
    begin
      assert_equal value_before, value_after
    rescue ASSERTION_FAILED_ERROR => e
      raise e, 'the value of expression changed in the block ' +
               "from #{value_before.inspect} to #{value_after.inspect}"
    end
  end
  
end

Test::Unit::TestCase.class_eval do
  include Elastatic::AssertionsExtension
end
