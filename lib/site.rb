require 'lib/section'

class Site
  
  OUTPUT_DIRECTORY = '_output'
  
  attr_reader :root_section
  
  def initialize
    @root_section = Section.new
  end
  
  def build!
    create_output_directory
    root_section.build!
    self
  end
  
  def clobber!
    return self unless File.directory?(OUTPUT_DIRECTORY)
    Kernel.system %Q(rm -fr "#{OUTPUT_DIRECTORY}")
    self
  end
  
private
  
  def create_output_directory
    Kernel.system %Q(mkdir -p "#{OUTPUT_DIRECTORY}")
    self
  end
  
end
