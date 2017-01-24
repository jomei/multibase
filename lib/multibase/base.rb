module Multibase
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection Multibase.config
  end
end