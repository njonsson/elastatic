unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/../lib/elastatic/require_relative_extension")
end
require_relative 'redcloth/lib/redcloth'
