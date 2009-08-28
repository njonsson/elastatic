require File.expand_path("#{File.dirname __FILE__}/elastatic/require_relative_extension")
require_relative { 'elastatic/inflections_extension' }
require_relative { 'renderers' }

class Entry
  
  attr_reader :path, :section
  
  def initialize(attributes={})
    @path    = attributes[:path].freeze
    @section = attributes[:section]
  end
  
  def build!
    transformation = transform
    Kernel.system %Q(mkdir -p "#{File.dirname transformation[:path]}")
    File.open transformation[:path], 'w' do |f|
      f.print transformation[:content]
    end
    self
  end
  
  def build_path
    transform[:path]
  end
  
  def index?
    ! (File.basename(path) =~ /^index(\.|$)/).nil?
  end
  
  def source
    File.read path
  end
  
  def title
    return section.title if index?
    File.basename(build_path).gsub(/\..*/, '').humanize.titleize
  end
  
private
  
  def transform
    transform_recursive :path => File.join(section.build_path,
                                           File.basename(path)),
                        :content => source
  end
  
  def transform_recursive(data)
    extname = File.extname(data[:path])
    return data unless (renderer = Renderers.choose(extname.gsub(/^\./, '')))
    transform_recursive :path => File.join(File.dirname(data[:path]),
                                           File.basename(data[:path], extname)),
                        :content => renderer.render(data[:content],
                                                    :scope => self,
                                                    :filename => data[:path])
  end
  
end
