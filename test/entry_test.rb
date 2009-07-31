require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'lib/entry'

module EntryTest
  
  module ClassMethods
    
    class New < Test::Unit::TestCase
      
      test 'should raise ArgumentError when sent with no arguments' do
        assert_raise ArgumentError do
          Entry.new
        end
      end
      
      test 'should set path attribute to argument' do
        assert_equal 'foo', Entry.new('foo').path
      end
      
    end
    
  end
  
end
