module Multibase
  class Base < ActiveRecord::Base
    self.abstract_class = true

    private
    mattr_accessor :database, instance_accessor: false

    def use_database(database_key)
      self.database = database_key
    end
  end
end