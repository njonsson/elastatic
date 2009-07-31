require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'vendor/mocha'
require 'lib/site'

module SiteTest
  
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
      @sections = [Section.new]
      Section.stubs(:find_in_root).returns @sections
      File.stubs(:read).returns 'Haml content goes here'
      @mock_haml_engine = mock('Haml::Engine')
      Haml::Engine.stubs(:new).returns @mock_haml_engine
      @mock_haml_engine.stubs(:render).returns 'HTML goes here'
      @mock_file = mock('IO')
      File.stubs(:open).yields @mock_file
      @mock_file.stubs :puts
      
      @site = Site.new
    end
    
    test 'should create the output directory' do
      Kernel.expects(:system).with 'mkdir -p "_output"'
      @site.build!
    end
    
    test 'should read index source file' do
      File.expects(:read).with('index.html.haml').returns 'Haml content goes here'
      @site.build!
    end
    
    test 'should instantiate Haml engine' do
      Haml::Engine.expects(:new).
                   with('Haml content goes here', :attr_wrapper => '"',
                                                  :filename => 'index.html.haml').
                   returns @mock_haml_engine
      @site.build!
    end
    
    test 'should send render to Haml engine' do
      @mock_haml_engine.expects(:render).
                        with anything, has_entries(:sections => @sections)
      @site.build!
    end
    
    test 'should open index output file' do
      File.expects(:open).with('_output/index.html', 'w').yields @mock_file
      @site.build!
    end
    
    test 'should write to index output file' do
      @mock_file.expects(:puts).with 'HTML goes here'
      @site.build!
    end
    
    test 'should return itself' do
      assert_same @site, @site.build!
    end
    
  end
  
end
