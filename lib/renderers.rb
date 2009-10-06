require File.expand_path("#{File.dirname __FILE__}/elastatic/require_relative_extension")
require_relative 'elastatic/inflections_extension'

module Renderers
  
  def self.choose(file_extension)
    Dir.glob File.expand_path("#{File.dirname __FILE__}/renderers/**/*.rb") do |f|
      basename = File.basename(f, '.rb')
      Kernel.require File.join(File.dirname(f), basename)
      klass = module_eval(basename.camelize).canonical_class
      return klass if klass.supported_file_extensions.include?(file_extension)
    end
    nil
  end
  
end
