module Elastatic; end

module Elastatic::ToProcExtension
  
  def to_proc
    Proc.new do |*args|
      args.shift.__send__ self, *args
    end
  end
  
end

Symbol.class_eval do
  include Elastatic::ToProcExtension
end
