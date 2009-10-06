require 'test/unit'
require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
require_relative '../../vendor/mocha'
require_relative '../../lib/elastatic/friendly_tests_extension'

class Elastatic::FriendlyTestNamesExtensionTest < Test::Unit::TestCase
  
  def setup
    @block_was_executed = false
    $stdout.stubs :puts
  end
  
  def do_define_test
    self.class.test '   Foo! Bar? Baz@#$%^&*()-"   ' do
      @block_was_executed = true
    end
  end
  
  def do_define_pending_test
    self.class.test 'should display a pending notification'
  end
  
  def do_define_disabled_test
    self.class.xtest 'should display a pending notification via xtest' do
      @block_was_executed = true
    end
  end
  
  def test_should_define_test_as_an_instance_method_with_the_expected_name
    do_define_test
    assert_respond_to self, 'test_Foo! Bar? Baz@#$%^&*()-"'
  end
  
  def test_should_execute_the_expected_block_when_the_test_method_is_called
    assert_equal false, @block_was_executed
    do_define_test
    send 'test_Foo! Bar? Baz@#$%^&*()-"'
    assert_equal true, @block_was_executed
  end
  
  def test_should_define_pending_test_as_an_instance_method_with_the_expected_name
    do_define_pending_test
    assert_respond_to self, 'test_should display a pending notification'
  end
  
  def test_should_write_to_stdout_when_the_pending_test_method_is_called
    do_define_pending_test
    pattern = create_notification_pattern('should display a pending notification')
    $stdout.expects(:puts).with regexp_matches(pattern)
    send 'test_should display a pending notification'
  end
  
  def test_should_not_execute_the_block_when_the_pending_test_method_is_called
    assert_equal false, @block_was_executed
    do_define_pending_test
    send 'test_should display a pending notification'
    assert_equal false, @block_was_executed
  end
  
  def test_should_define_disabled_test_as_an_instance_method_with_the_expected_name
    do_define_disabled_test
    assert_respond_to self, 'test_should display a pending notification via xtest'
  end
  
  def test_should_write_to_stdout_when_the_disabled_test_method_is_called
    do_define_disabled_test
    pattern = create_notification_pattern('should display a pending notification via xtest')
    $stdout.expects(:puts).with regexp_matches(pattern)
    send 'test_should display a pending notification via xtest'
  end
  
  def test_should_not_execute_the_block_when_the_disabled_test_method_is_called
    assert_equal false, @block_was_executed
    do_define_disabled_test
    send 'test_should display a pending notification via xtest'
    assert_equal false, @block_was_executed
  end
  
private
  
  def create_notification_pattern(message)
    /^\n\*\*\* PENDING at #{File.expand_path __FILE__}:.+?: #{message}$/
  end
  
end
