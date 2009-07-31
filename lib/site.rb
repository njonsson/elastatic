require 'lib/section'
require 'vendor/haml'

class Site
  
  OUTPUT_DIRECTORY = '_output'
  
  def build!
    create_output_directory
    render_index
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
  
  def prepare_locals
    {:sections => Section.find_in_root}
  end
  
  def render_index
    filename = 'index.html.haml'
    scope = Object.new
    locals = prepare_locals
    html = Haml::Engine.new(File.read(filename),
                            :attr_wrapper => '"',
                            :filename => filename).render scope, locals
    File.open "#{OUTPUT_DIRECTORY}/index.html", 'w' do |f|
      f.puts html
    end
    self
  end
  
end
