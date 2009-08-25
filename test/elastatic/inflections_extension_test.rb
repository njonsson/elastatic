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
  
  class Humanize < Test::Unit::TestCase
    
    test 'should break words at underscores and hyphens' do
      assert_equal 'the quick brown fox jumped over the lazy dog',
                   'the_quick-brown-fox_jumped_over_the_lazy-dog'.humanize
    end
    
    test 'should not disturb multiple underscores' do
      assert_equal 'foo__bar', 'foo__bar'.humanize
    end
    
    test 'should not disturb multiple hyphens' do
      assert_equal 'foo--bar', 'foo--bar'.humanize
    end
    
    test 'should not disturb a leading underscore' do
      assert_equal '_foo', '_foo'.humanize
    end
    
    test 'should not disturb a trailing underscore' do
      assert_equal 'foo_', 'foo_'.humanize
    end
    
    test 'should not disturb a leading hyphen' do
      assert_equal '-foo', '-foo'.humanize
    end
    
    test 'should not disturb a trailing hyphen' do
      assert_equal 'foo-', 'foo-'.humanize
    end
    
  end
  
end
