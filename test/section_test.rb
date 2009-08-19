require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'vendor/mocha'
require 'lib/section'

module SectionTest
  
  module ClassMethods
    
    class BuildPathFor < Test::Unit::TestCase
      
      test 'should not affect simple paths' do
        assert_equal '_output/foo', Section.build_path_for('foo')
      end
      
      test 'should not affect simple deep paths' do
        assert_equal '_output/foo/bar/baz', Section.build_path_for('foo/bar/baz')
      end
      
      test 'should remove trailing "-content" from all directory names in deep paths' do
        assert_equal '_output/foo/bar/baz/bat',
                     Section.build_path_for('foo-content/bar/baz-content/bat')
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
    
    class Build < ForRoot
      
      def setup
        super
        @mock_entry = mock('Entry')
        @section.stubs(:entries).returns [@mock_entry]
        @mock_entry.stubs(:build!).returns @mock_entry
      end
      
      test 'should find entries' do
        @section.expects(:entries).returns [@mock_entry]
        @section.build!
      end
      
      test 'should build each entry' do
        @mock_entry.expects(:build!).returns @mock_entry
        @section.build!
      end
      
      test 'should return itself' do
        assert_same @section, @section.build!
      end
      
    end
    
    class Entries < ForRoot
      
      def setup
        super
        Dir.stubs(:glob).yields 'index.html.haml'
        File.stubs(:file?).returns true
        Entry.stubs(:new).returns :an_entry_object
      end
      
      test 'should search for filesystem entries in root' do
        Dir.expects(:glob).with('[^_]*').yields 'index.html.haml'
        @section.entries
      end
      
      test 'should verify that filesystem entries are files' do
        File.expects(:file?).with('index.html.haml').returns true
        @section.entries
      end
      
      test 'should instantiate a new Entry for each entry file' do
        Entry.expects(:new).with('index.html.haml').returns :an_entry_object
        @section.entries
      end
      
      test 'should not instantiate a new Entry for non-files' do
        File.stubs(:file?).returns false
        Entry.expects(:new).never
        @section.entries
      end
      
      test 'should return the instantiated Entry objects' do
        assert_equal [:an_entry_object], @section.entries
      end
      
    end
    
    class Subsections < ForRoot
      
      def setup
        super
        Dir.stubs(:glob).yields 'foo-content'
        File.stubs(:directory?).returns true
        Section.stubs(:new).returns :a_section_object
      end
      
      test 'should search for content directories in root' do
        Dir.expects(:glob).with('*-content').yields 'foo-content'
        @section.subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('foo-content').returns true
        @section.subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        Section.expects(:new).with('foo-content').returns :a_section_object
        @section.subsections
      end
      
      test 'should not instantiate a new Section for non-directories' do
        File.stubs(:directory?).returns false
        Section.expects(:new).never
        @section.subsections
      end
      
      test 'should return the instantiated Section objects' do
        assert_equal [:a_section_object], @section.subsections
      end
      
    end
    
    class Title < ForRoot
      
      def setup
        super
        File.stubs(:exist?).returns false
      end
      
      test 'should look for existence of section configuration file in root' do
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
        
        test 'should read section configuration file in root' do
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
    
    class Build < ForDeepDirectory
      
      def setup
        super
        @mock_entry = mock('Entry')
        @section.stubs(:entries).returns [@mock_entry]
        @mock_entry.stubs(:build!).returns @mock_entry
      end
      
      test 'should find entries' do
        @section.expects(:entries).returns [@mock_entry]
        @section.build!
      end
      
      test 'should build each entry' do
        @mock_entry.expects(:build!).returns @mock_entry
        @section.build!
      end
      
      test 'should return itself' do
        assert_same @section, @section.build!
      end
      
    end
    
    class Entries < ForDeepDirectory
      
      def setup
        super
        Dir.stubs(:glob).yields 'dir/goes/here/index.html.haml'
        File.stubs(:file?).returns true
        Entry.stubs(:new).returns :an_entry_object
      end
      
      test 'should combine path and entry name pattern' do
        File.expects(:join).with('dir/goes/here', '[^_]*').returns 'dir/goes/here/[^_]*'
        @section.entries
      end
      
      test 'should search for filesystem entries in path' do
        Dir.expects(:glob).with('dir/goes/here/[^_]*').yields 'index.html.haml'
        @section.entries
      end
      
      test 'should verify that filesystem entries are files' do
        File.expects(:file?).with('dir/goes/here/index.html.haml').returns true
        @section.entries
      end
      
      test 'should instantiate a new Entry for each entry file' do
        Entry.expects(:new).with('dir/goes/here/index.html.haml').returns :an_entry_object
        @section.entries
      end
      
      test 'should not instantiate a new Entry for non-files' do
        File.stubs(:file?).returns false
        Entry.expects(:new).never
        @section.entries
      end
      
      test 'should return the instantiated Entry objects' do
        assert_equal [:an_entry_object], @section.entries
      end
      
    end
    
    class Subsections < ForDeepDirectory
      
      def setup
        super
        Dir.stubs(:glob).yields 'dir/goes/here/foo-content'
        File.stubs(:directory?).returns true
      end
      
      test 'should combine path and directory name pattern' do
        File.expects(:join).with('dir/goes/here', '*-content').returns 'dir/goes/here/*-content'
        @section.subsections
      end
      
      test 'should search for content directories in path' do
        Dir.expects(:glob).with('dir/goes/here/*-content').yields 'foo-content'
        @section.subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('dir/goes/here/foo-content').returns true
        @section.subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        Section.expects(:new).with('dir/goes/here/foo-content').returns :a_section_object
        @section.subsections
      end
      
      test 'should not instantiate a new Section for non-directories' do
        File.stubs(:directory?).returns false
        Section.expects(:new).never
        @section.subsections
      end
      
      test 'should return the instantiated Section objects' do
        Section.stubs(:new).returns :a_section_object
        assert_equal [:a_section_object], @section.subsections
      end
      
    end
    
    class Title < ForDeepDirectory
      
      def setup
        super
        File.stubs(:exist?).returns false
        Section.stubs(:build_path_for).returns 'dir/goes/here'
      end
      
      test 'should combine empty string path and section configuration filename' do
        File.expects(:join).with('dir/goes/here', '_config.yml').returns '_config.yml'
        @section.title
      end
      
      test 'should look for existence of section configuration file in path' do
        File.expects(:exist?).with('dir/goes/here/_config.yml').returns false
        @section.title
      end
      
      class WithoutSectionConfigurationFile < Title
        
        def setup
          super
          @build_path = 'dir/goes/here'
          Section.stubs(:build_path_for).returns @build_path
          @basename = 'here'
          File.stubs(:basename).returns @basename
          @basename.stubs(:titleize).returns 'Here'
        end
        
        test 'should obtain the build path for the path' do
          Section.expects(:build_path_for).
                  with('dir/goes/here').
                  returns @build_path
          @section.title
        end
        
        test 'should obtain the basename of the build path' do
          File.expects(:basename).with(@build_path).returns @basename
          @section.title
        end
        
        test 'should titleize the basename' do
          @basename.expects(:titleize).returns 'Here'
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
        
        test 'should read section configuration file in path' do
          File.expects(:read).with('dir/goes/here/_config.yml').returns ''
          @section.title
        end
        
        class LackingTitleOption < WithSectionConfigurationFile
          
          def setup
            super
            @build_path = 'dir/goes/here'
            Section.stubs(:build_path_for).returns @build_path
            @basename = 'here'
            File.stubs(:basename).returns @basename
            @basename.stubs(:titleize).returns 'Here'
          end
          
          test 'should obtain the build path for the path' do
            Section.expects(:build_path_for).
                    with('dir/goes/here').
                    returns @build_path
            @section.title
          end
          
          test 'should obtain the basename of the build path' do
            File.expects(:basename).with(@build_path).returns @basename
            @section.title
          end
          
          test 'should titleize the basename' do
            @basename.expects(:titleize).returns 'Here'
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
