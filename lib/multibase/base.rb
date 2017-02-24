module Multibase
  class Base < ActiveRecord::Base
    self.abstract_class = true

    protected
    mattr_accessor :database, instance_accessor: false

    def self.use_database(database_key)
      self.database = database_key
      establish_connection Multibase.config database_key.to_s
    end
  end
end