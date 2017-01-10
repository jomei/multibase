module Multibase
  class Base < ActiveRecord::Base
    self.abstract_class = true
    binding.pry
    establish_connection Multibase.config
  end
end