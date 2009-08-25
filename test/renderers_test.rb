require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'vendor/mocha'
require 'lib/renderers'

module RenderersTest
  
  class Choose < Test::Unit::TestCase
    
    def setup
      Dir.stubs(:glob).yields 'lib/renderers/foo.rb'
      Kernel.stubs :require
      @mock_class = mock('Class')
      Renderers.stubs(:module_eval).returns @mock_class
      @mock_canonicalized_class = mock('Class')
      @mock_class.stubs(:canonical_class).returns @mock_canonicalized_class
      @mock_canonicalized_class.stubs(:supported_file_extensions).
                                returns %w(foo)
    end
    
    test 'should search for renderers' do
      Dir.expects(:glob).yields 'lib/renderers/foo.rb'
      Renderers.choose 'foo'
    end
    
    test 'should require renderer source file by canonical name' do
      Kernel.expects(:require).with('lib/renderers/foo')
      Renderers.choose 'foo'
    end
    
    test 'should convert renderer source file name into class' do
      Renderers.expects(:module_eval).with('Foo').returns @mock_class
      Renderers.choose 'foo'
    end
    
    test 'should canonicalize renderer class' do
      @mock_class.expects(:canonical_class).returns @mock_canonicalized_class
      Renderers.choose 'foo'
    end
    
    test 'should interrogate the canonicalized class about support for the file extension' do
      @mock_canonicalized_class.expects(:supported_file_extensions).
                                returns %w(foo)
      Renderers.choose 'foo'
    end
    
    class WithSupportForFileExtension < Choose
      
      test 'should return canonicalized renderer class' do
        assert_same @mock_canonicalized_class, Renderers.choose('foo')
      end
      
    end
    
    class WithoutSupportForFileExtension < Choose
      
      test 'should return nil' do
        @mock_canonicalized_class.stubs(:supported_file_extensions).
                                  returns %w(bar)
        assert_nil Renderers.choose('foo')
      end
      
    end
    
  end
  
end