module Elastatic; end

module Elastatic::RequireRelativeExtension
  
  def require_relative(relative_path)
    absolute_path = File.expand_path(File.join(File.dirname(caller.first),
                                               relative_path))
    Kernel.require absolute_path
  end
  
end

Object.class_eval do
  include Elastatic::RequireRelativeExtension
end
