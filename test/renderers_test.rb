require 'test/unit'
require File.expand_path("#{File.dirname __FILE__}/../lib/elastatic/require_relative_extension")
require_relative '../vendor/mocha'
require_relative '../lib/elastatic/friendly_tests_extension'
require_relative '../lib/renderers'

module RenderersTest
  
  class Choose < Test::Unit::TestCase
    
    def setup
      Dir.stubs(:glob).yields '/path/to/install/lib/renderers/foo.rb'
      Kernel.stubs :require
      @class = Class.new
      Renderers.stubs(:module_eval).returns @class
      @canonicalized_class = Class.new
      @class.stubs(:canonical_class).returns @canonicalized_class
      @canonicalized_class.stubs(:supported_file_extensions).returns %w(foo)
    end
    
    test 'should search for renderers' do
      Dir.expects(:glob).
          with(File.expand_path("#{File.dirname __FILE__}/../lib/renderers/**/*.rb")).
          yields '/path/to/install/lib/renderers/foo.rb'
      Renderers.choose 'foo'
    end
    
    test 'should require renderer source file by canonical name' do
      Kernel.expects(:require).with '/path/to/install/lib/renderers/foo'
      Renderers.choose 'foo'
    end
    
    test 'should convert renderer source file name into class' do
      Renderers.expects(:module_eval).with('Foo').returns @class
      Renderers.choose 'foo'
    end
    
    test 'should canonicalize renderer class' do
      @class.expects(:canonical_class).with().returns @canonicalized_class
      Renderers.choose 'foo'
    end
    
    test 'should interrogate the canonicalized class about support for the file extension' do
      @canonicalized_class.expects(:supported_file_extensions).
                           with().
                           returns %w(foo)
      Renderers.choose 'foo'
    end
    
    class WithSupportForFileExtension < Choose
      
      test 'should return canonicalized renderer class' do
        assert_same @canonicalized_class, Renderers.choose('foo')
      end
      
    end
    
    class WithoutSupportForFileExtension < Choose
      
      test 'should return nil' do
        @canonicalized_class.stubs(:supported_file_extensions).returns %w(bar)
        assert_nil Renderers.choose('foo')
      end
      
    end
    
  end
  
end
