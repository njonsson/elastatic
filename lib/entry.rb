require 'lib/renderers'
require 'lib/site'

class Entry
  
  attr_reader :path
  
  def initialize(path)
    @path = path.freeze
  end
  
  def build!
    transformation = transform(:path => build_path, :content => source)
    Kernel.system %Q(mkdir -p "#{File.dirname transformation[:path]}")
    File.open transformation[:path], 'w' do |f|
      f.print transformation[:content]
    end
    self
  end
  
  def build_path
    File.join Section.build_path_for(File.dirname(path)), File.basename(path)
  end
  
  def source
    File.read path
  end
  
private
  
  def transform(data)
    extname = File.extname(data[:path])
    return data unless (renderer = Renderers.choose(extname.gsub(/^\./, '')))
    transform :path => File.join(File.dirname(data[:path]),
                                 File.basename(data[:path], extname)),
              :content => renderer.render(data[:content],
                                          :filename => data[:path])
  end
  
end
