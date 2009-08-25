require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'vendor/mocha'
require 'lib/site'

module SiteTest
  
  class RootSection < Test::Unit::TestCase
    
    def setup
      @site = Site.new
    end
    
    test 'should return a Section with root path' do
      assert_nil @site.root_section.path
    end
    
    test 'should maintain as an attribute' do
      assert_same @site.root_section, @site.root_section
    end
    
  end
  
  class Clobber < Test::Unit::TestCase
    
    def setup
      File.stubs(:directory?).returns false
      @site = Site.new
    end
    
    test 'should check to see if output directory exists' do
      File.expects(:directory?).with('_output').returns false
      @site.clobber!
    end
    
    test 'should return itself' do
      assert_same @site, @site.clobber!
    end
    
    class WhereOutputDirectoryExists < Clobber
      
      def setup
        super
        File.stubs(:directory?).returns true
        Kernel.stubs :system
      end
      
      test 'should remove the output directory' do
        Kernel.expects(:system).with 'rm -fr "_output"'
        @site.clobber!
      end
      
    end
    
    class WhereOutputDirectoryDoesNotExist < Clobber
      
      test 'should not attempt to remove the output directory' do
        Kernel.expects(:system).never
        @site.clobber!
      end
      
    end
    
  end
  
  class Build < Test::Unit::TestCase
    
    def setup
      Kernel.stubs :system
      @site = Site.new
      @mock_section = mock('Section')
      @site.stubs(:root_section).returns @mock_section
      @mock_section.stubs :build!
    end
    
    test 'should create the output directory' do
      Kernel.expects(:system).with 'mkdir -p "_output"'
      @site.build!
    end
    
    test 'should use the root section' do
      @site.expects(:root_section).with().returns @mock_section
      @site.build!
    end
    
    test 'should build the root section' do
      @mock_section.expects(:build!).with().returns @mock_section
      @site.build!
    end
    
    test 'should return itself' do
      assert_same @site, @site.build!
    end
    
  end
  
end
