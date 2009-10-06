module RequireRelativeExtension
  
  def require_relative(&block_returning_relative_path)
    binding_of_caller = block_returning_relative_path.binding
    relative_path = block_returning_relative_path.call
    path_expression = 'File.expand_path File.join(File.dirname(__FILE__), ' +
                                                 "#{relative_path.inspect})"
    absolute_path = binding_of_caller.send(:eval, path_expression)
    Kernel.require absolute_path
  end
  
end

Object.class_eval do
  include RequireRelativeExtension
end
