require 'pry'
module Multibase

  mattr_accessor :connected, instance_accessor: false
  self.connected = false

  def self.exec(connection_name)
    binding.pry
    return yield if connected
    multibase_config = Multibase::Railtie.database_configuration
    ActiveRecord::Tasks::DatabaseTasks.current_config = config(connection_name)

    ActiveRecord::Base.configurations = multibase_config[connection_name]
    ActiveRecord::Base.establish_connection(config(connection_name))
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [Multibase::Railtie.fullpath('migrate')]
    ActiveRecord::Tasks::DatabaseTasks.db_dir = Multibase::Railtie.fullpath
    ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    self.connected = true
    yield
  end
end