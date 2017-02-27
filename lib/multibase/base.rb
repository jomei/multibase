module Multibase
  class Base < ActiveRecord::Base
    self.abstract_class = true

    def self.using(database_key)
      @database = database_key
      Multibase.apply database_key.to_s
    end
  end
end