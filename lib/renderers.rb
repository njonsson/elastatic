require 'lib/elastatic/inflections_extension'

module Renderers
  
  def self.choose(file_extension)
    Dir.glob 'lib/renderers/**/*.rb' do |f|
      basename = File.basename(f, '.rb')
      Kernel.require File.join(File.dirname(f), basename)
      klass = module_eval(basename.camelize).canonical_class
      return klass if klass.supported_file_extensions.include?(file_extension)
    end
    nil
  end
  
end
