module Multibase
  mattr_accessor :connected, instance_accessor: false
  self.connected = false

  def self.exec(connection_name)
    multibase_config = Multibase::Railtie.database_configuration
    ActiveRecord::Tasks::DatabaseTasks.current_config = config(connection_name)
    connection_dir_path = Multibase::Railtie.fullpath(connection_name)
    ActiveRecord::Base.configurations = multibase_config[connection_name]
    ActiveRecord::Base.establish_connection(config(connection_name))
    migration_paths = [connection_dir_path.join('migrate')]
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = migration_paths
    ActiveRecord::Tasks::DatabaseTasks.db_dir = connection_dir_path
    ActiveRecord::Migrator.migrations_paths = migration_paths
    yield
  end
end