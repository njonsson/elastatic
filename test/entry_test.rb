require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'vendor/mocha'
require 'lib/entry'

class EntryTest < Test::Unit::TestCase
  
  module ClassMethods
    
    class New < Test::Unit::TestCase
      
      test 'should raise ArgumentError when sent with no arguments' do
        assert_raise ArgumentError do
          Entry.new
        end
      end
      
      test 'should set path attribute to argument' do
        assert_equal 'dir/goes/here/foo', Entry.new('dir/goes/here/foo').path
      end
      
    end
    
  end
  
  def setup
    @entry = Entry.new('dir/goes/here/foo')
  end
  
  test 'should be immutable' do
    assert_raise NoMethodError do
      @entry.path = 'bar'
    end
    assert_raise TypeError do
      @entry.path.gsub! 'foo', 'bar'
    end
  end
  
  class Source < EntryTest
    
    def setup
      super
      File.stubs(:read).returns 'content goes here'
    end
    
    test 'should read the file' do
      File.expects(:read).with('dir/goes/here/foo').returns 'content goes here'
      @entry.source
    end
    
    test 'should return the source' do
      assert_equal 'content goes here', @entry.source
    end
    
  end
  
  class Build < EntryTest
    
    def setup
      super
      @entry.stubs(:source).returns 'content goes here'
      Renderers.stubs(:choose).returns nil
      Kernel.stubs :system
      @mock_file = mock('File')
      File.stubs(:open).yields @mock_file
      @mock_file.stubs :print
    end
    
    test 'should read the source' do
      @entry.expects(:source).with().returns 'content goes here'
      @entry.build!
    end
    
    test 'should ensure that the output subdirectory exists' do
      Kernel.expects(:system).with 'mkdir -p "_output/dir/goes/here"'
      @entry.build!
    end
    
    test 'should return itself' do
      assert_same @entry, @entry.build!
    end
    
    class WithNoFileExtension < Build
      
      test 'should choose a renderer for an empty file extension' do
        Renderers.expects(:choose).with('').returns nil
        @entry.build!
      end
      
      test 'should open the output file for write access' do
        File.expects(:open).
             with('_output/dir/goes/here/foo', 'w').
             yields @mock_file
        @entry.build!
      end
      
      test 'should write the source to the output subdirectory' do
        @mock_file.expects(:print).with 'content goes here'
        @entry.build!
      end
      
    end
    
    class WithOneRenderableAndOneUnrenderableFileExtension < Build
      
      def setup
        super
        @entry.stubs(:path).returns 'dir/goes/here/foo.html.haml'.freeze
        @mock_haml_renderer = mock('Renderers::Haml')
        Renderers.stubs(:choose).
                  with('haml').
                  returns @mock_haml_renderer
        @mock_haml_renderer.stubs(:render).returns 'rendered content goes here'
        Renderers.stubs(:choose).
                  with('html').
                  returns nil
      end
      
      test 'should choose a renderer for the first file extension' do
        Renderers.expects(:choose).with('haml').returns @mock_haml_renderer
        @entry.build!
      end
      
      test 'should use the first renderer' do
        @mock_haml_renderer.expects(:render).
                            with('content goes here',
                                 :filename => '_output/dir/goes/here/foo.html.haml').
                            returns 'rendered content goes here'
        @entry.build!
      end
      
      test 'should choose a renderer for the second file extension' do
        Renderers.expects(:choose).with('html').returns nil
        @entry.build!
      end
      
      test 'should open the output file for write access' do
        File.expects(:open).
             with('_output/dir/goes/here/foo.html', 'w').
             yields @mock_file
        @entry.build!
      end
      
      test 'should write the rendered content to the output subdirectory' do
        @mock_file.expects(:print).with 'rendered content goes here'
        @entry.build!
      end
      
    end
    
  end
  
  class BuildPath < EntryTest
    
    test 'should remove "-content" suffixes from section names' do
      @entry.stubs(:path).returns 'dir-content/goes/here-content/foo'
      assert_equal '_output/dir/goes/here/foo', @entry.build_path
    end
    
    test 'should not remove "-content" suffix from entry name' do
      @entry.stubs(:path).returns 'dir/goes/here/foo-content'
      assert_equal '_output/dir/goes/here/foo-content', @entry.build_path
    end
    
  end
  
end
