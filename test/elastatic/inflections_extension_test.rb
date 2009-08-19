require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'lib/elastatic/inflections_extension'

module Elastatic::InflectionsExtensionTest
  
  class Titleize < Test::Unit::TestCase
    
    test 'should capitalize lowercase words' do
      assert_equal 'The Quick, Brown Fox Jumped Over The Lazy Dog',
                   'the quick, brown fox jumped over the lazy dog'.titleize
    end
    
    test 'should not disturb capitals' do
      assert_equal 'HAL Was IBM Shifted By One Letter',
                   'HAL was IBM shifted by one letter'.titleize
    end
    
  end
  
  class Camelize < Test::Unit::TestCase
    
    test 'should camelize underscored words' do
      assert_equal 'TheQuickBrownFoxJumpedOverTheLazyDog',
                   'the_quick_brown_fox_jumped_over_the_lazy_dog'.camelize
    end
    
    test 'should not disturb capitals' do
      assert_equal 'HALWasIBMShiftedByOneLetter',
                   'HAL_was_IBM_shifted_by_one_letter'.camelize
    end
    
  end
  
end
