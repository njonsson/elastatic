require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'vendor/mocha'
require 'lib/section'

module SectionTest
  
  module ClassMethods
    
    class FindInRoot < Test::Unit::TestCase
      
      def setup
        @mock_section = mock('Section')
        Section.stubs(:new).returns @mock_section
        @mock_section.stubs(:find_subsections).returns [:a_section_object]
      end
      
      test 'should instantiate a new root-level Section' do
        Section.expects(:new).with().returns @mock_section
        Section.find_in_root
      end
      
      test 'should send find_subsections on the root-level Section' do
        @mock_section.expects(:find_subsections).with()
        Section.find_in_root
      end
      
      test 'should return the result of find_subsections on the root-level Section' do
        assert_equal [:a_section_object], Section.find_in_root
      end
      
    end
    
    class New < Test::Unit::TestCase
      
      test 'should set path attribute to nil when sent with no arguments' do
        assert_nil Section.new.path
      end
      
      test 'should set path attribute to argument' do
        assert_equal 'foo', Section.new('foo').path
      end
      
    end
    
  end
  
  class ForRoot < Test::Unit::TestCase
    
    def setup
      @section = Section.new
    end
    
    test 'should have nil path' do
      assert_nil @section.path
    end
    
    class FindSubsections < ForRoot
      
      def setup
        super
        Dir.stubs(:glob).yields 'foo-content'
        File.stubs(:directory?).returns true
      end
      
      test 'should search for content directories' do
        Dir.expects(:glob).with('*-content').yields 'foo-content'
        @section.find_subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('foo-content').returns true
        @section.find_subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        Section.expects(:new).with('foo-content').returns :a_section_object
        @section.find_subsections
      end
      
      test 'should not instantiate a new Section for non-directories' do
        File.stubs(:directory?).returns false
        Section.expects(:new).never
        @section.find_subsections
      end
      
      test 'should return the instantiated Section objects' do
        Section.stubs(:new).returns :a_section_object
        assert_equal [:a_section_object], @section.find_subsections
      end
      
    end
    
    class Title < ForRoot
      
      def setup
        super
        File.stubs(:exist?).returns false
      end
      
      test 'should look for existence of section configuration file' do
        File.expects(:exist?).with('_config.yml').returns false
        @section.title
      end
      
      class WithoutSectionConfigurationFile < Title
        
        test 'should return nil' do
          assert_nil @section.title
        end
        
      end
      
      class WithSectionConfigurationFile < Title
        
        def setup
          super
          File.stubs(:exist?).returns true
          File.stubs(:read).returns ''
          YAML.stubs(:load).returns false
        end
        
        test 'should read section configuration file' do
          File.expects(:read).with('_config.yml').returns ''
          @section.title
        end
        
        class LackingTitleOption < WithSectionConfigurationFile
          
          test 'should return nil' do
            assert_nil @section.title
          end
          
        end
        
        class HavingTitleOption < WithSectionConfigurationFile
          
          def setup
            super
            File.stubs(:read).returns 'title: foo'
            YAML.stubs(:load).returns({'title' => 'foo'})
          end
          
          test 'should interpret section configuration file as YAML' do
            YAML.expects(:load).with('title: foo').returns({'title' => 'foo'})
            @section.title
          end
          
          test 'should return configured title' do
            assert_equal 'foo', @section.title
          end
          
        end
        
      end
      
    end
    
  end
  
  class ForDeepDirectory < Test::Unit::TestCase
    
    def setup
      @section = Section.new('dir/goes/here')
    end
    
    test 'should have expected path' do
      assert_equal 'dir/goes/here', @section.path
    end
    
    class FindSubsections < ForDeepDirectory
      
      def setup
        super
        Dir.stubs(:glob).yields 'dir/goes/here/foo-content'
        File.stubs(:directory?).returns true
      end
      
      test 'should combine path and directory name pattern' do
        File.expects(:join).with('dir/goes/here', '*-content').returns 'dir/goes/here/*-content'
        @section.find_subsections
      end
      
      test 'should search for content directories' do
        Dir.expects(:glob).with('dir/goes/here/*-content').yields 'foo-content'
        @section.find_subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('dir/goes/here/foo-content').returns true
        @section.find_subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        Section.expects(:new).with('dir/goes/here/foo-content').returns :a_section_object
        @section.find_subsections
      end
      
      test 'should not instantiate a new Section for non-directories' do
        File.stubs(:directory?).returns false
        Section.expects(:new).never
        @section.find_subsections
      end
      
      test 'should return the instantiated Section objects' do
        Section.stubs(:new).returns :a_section_object
        assert_equal [:a_section_object], @section.find_subsections
      end
      
    end
    
    class Title < ForDeepDirectory
      
      def setup
        super
        File.stubs(:exist?).returns false
      end
      
      test 'should combine empty string path and section configuration filename' do
        File.expects(:join).with('dir/goes/here', '_config.yml').returns '_config.yml'
        @section.title
      end
      
      test 'should look for existence of section configuration file' do
        File.expects(:exist?).with('dir/goes/here/_config.yml').returns false
        @section.title
      end
      
      class WithoutSectionConfigurationFile < Title
        
        def setup
          super
          @directory_name = 'here'
          File.stubs(:basename).returns @directory_name
          @directory_name.stubs(:gsub).returns @directory_name
          @directory_name.stubs(:titleize).returns 'Here'
        end
        
        test 'should extract directory name from path' do
          File.expects(:basename).with('dir/goes/here').returns @directory_name
          @section.title
        end
        
        test 'should remove trailing "-content" from directory name' do
          @directory_name.expects(:gsub).with(/-content$/, '').returns 'here'
          @section.title
        end
        
        test 'should titleize directory name' do
          @directory_name.expects(:titleize).returns 'Here'
          @section.title
        end
        
        test 'should return titleized directory name' do
          assert_equal 'Here', @section.title
        end
        
      end
      
      class WithSectionConfigurationFile < Title
        
        def setup
          super
          File.stubs(:exist?).returns true
          File.stubs(:read).returns ''
          YAML.stubs(:load).returns false
        end
        
        test 'should read section configuration file' do
          File.expects(:read).with('dir/goes/here/_config.yml').returns ''
          @section.title
        end
        
        class LackingTitleOption < WithSectionConfigurationFile
          
          def setup
            super
            @directory_name = 'here'
            File.stubs(:basename).returns @directory_name
            @directory_name.stubs(:gsub).returns @directory_name
            @directory_name.stubs(:titleize).returns 'Here'
          end
          
          test 'should remove trailing "-content" from directory name' do
            @directory_name.expects(:gsub).with(/-content$/, '').returns 'here'
            @section.title
          end
          
          test 'should titleize the directory name' do
            @directory_name.expects(:titleize).returns 'Here'
            @section.title
          end
          
          test 'should return titleized directory name' do
            assert_equal 'Here', @section.title
          end
          
        end
        
        class HavingTitleOption < WithSectionConfigurationFile
          
          def setup
            super
            File.stubs(:read).returns 'title: foo'
            YAML.stubs(:load).returns({'title' => 'foo'})
          end
          
          test 'should interpret section configuration file as YAML' do
            YAML.expects(:load).with('title: foo').returns({'title' => 'foo'})
            @section.title
          end
          
          test 'should return configured title' do
            assert_equal 'foo', @section.title
          end
          
        end
        
      end
      
    end
    
  end
  
end
