require 'pry'
module Multibase
  mattr_accessor :connected, instance_accessor: false
  self.connected = false

  def self.exec(connection_name)
    return yield if connected
    multibase_config = Multibase::Railtie.database_configuration
    ActiveRecord::Tasks::DatabaseTasks.current_config = config(connection_name)

    ActiveRecord::Base.configurations = multibase_config[connection_name]
    ActiveRecord::Base.establish_connection(config(connection_name))
    migration_paths = [Multibase::Railtie.fullpath('migrate').join(connection_name)]
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = migration_paths
    ActiveRecord::Tasks::DatabaseTasks.db_dir = Multibase::Railtie.fullpath
    ActiveRecord::Migrator.migrations_paths = migration_paths

    self.connected = true
    yield
  end
end